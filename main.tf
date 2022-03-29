locals {
  # Use `local.vpc_id` to give a hint to Terraform that subnets should be deleted before secondary CIDR blocks can be free!
  vpc_id = try(aws_vpc_ipv4_cidr_block_association.this[0].vpc_id, aws_vpc.this[0].id, null)
}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "this" {
  count = var.create ? 1 : 0

  cidr_block          = var.ipv4_cidr_block
  ipv4_ipam_pool_id   = var.ipv4_ipam_pool_id
  ipv4_netmask_length = var.ipv4_netmask_length

  ipv6_cidr_block                      = var.ipv6_cidr_block
  ipv6_ipam_pool_id                    = var.ipv6_ipam_pool_id
  ipv6_netmask_length                  = var.ipv6_netmask_length
  ipv6_cidr_block_network_border_group = var.ipv6_cidr_block_network_border_group
  assign_generated_ipv6_cidr_block     = var.assign_generated_ipv6_cidr_block

  instance_tenancy               = var.instance_tenancy
  enable_dns_support             = var.enable_dns_support
  enable_dns_hostnames           = var.enable_dns_hostnames
  enable_classiclink             = var.enable_classiclink
  enable_classiclink_dns_support = var.enable_classiclink_dns_support

  tags = merge(
    var.tags,
    { Name = var.name },
    var.vpc_tags,
  )
}

################################################################################
# VPC CIDR Block Association(s)
################################################################################

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  for_each = { for k, v in var.ipv4_cidr_block_associations : k => v if var.create }

  vpc_id              = aws_vpc.this[0].id
  cidr_block          = try(each.value.ipv4_cidr_block, null)
  ipv4_ipam_pool_id   = try(each.value.ipv4_ipam_pool_id, null)
  ipv4_netmask_length = try(each.value.ipv4_netmask_length, null)

  timeouts {
    create = try(each.value.timeouts.create, null)
    delete = try(each.value.timeouts.delete, null)
  }
}

resource "aws_vpc_ipv6_cidr_block_association" "this" {
  for_each = { for k, v in var.ipv6_cidr_block_associations : k => v if var.create }

  vpc_id              = aws_vpc.this[0].id
  ipv6_cidr_block     = try(each.value.ipv6_cidr_block, null)
  ipv6_ipam_pool_id   = try(each.value.ipv6_ipam_pool_id, null)
  ipv6_netmask_length = try(each.value.ipv6_netmask_length, null)

  timeouts {
    create = try(each.value.timeouts.create, null)
    delete = try(each.value.timeouts.delete, null)
  }
}

################################################################################
# Route53 Resolver
################################################################################

resource "aws_route53_resolver_dnssec_config" "this" {
  count = var.create && var.enable_dnssec_config ? 1 : 0

  resource_id = aws_vpc.this[0].id
}

# Route53 resolver query log config is shareable via RAM
# https://docs.aws.amazon.com/ram/latest/userguide/shareable.html#shareable-r53
# So users can enable query logging but provide the externally created config ID:
# enable_dns_query_logging        = true
# create_dns_query_logging_config = false
# dns_query_loggin_config         = "<externally-created>"
resource "aws_route53_resolver_query_log_config" "this" {
  count = var.create && var.enable_dns_query_logging && var.create_dns_query_log_config ? 1 : 0

  name            = var.name
  destination_arn = var.dns_query_log_destintion_arn

  tags = var.tags
}

resource "aws_route53_resolver_query_log_config_association" "this" {
  count = var.create && var.enable_dns_query_logging ? 1 : 0

  resolver_query_log_config_id = var.create_dns_query_log_config ? aws_route53_resolver_query_log_config.this[0].id : var.dns_query_log_config_id
  resource_id                  = aws_vpc.this[0].id
}

################################################################################
# DNS Firewall Rule Group Association
################################################################################

resource "aws_route53_resolver_firewall_config" "this" {
  count = var.create && var.enable_dns_firewall ? 1 : 0

  resource_id        = aws_vpc.this[0].id
  firewall_fail_open = var.dns_firewall_fail_open
}

resource "aws_route53_resolver_firewall_rule_group_association" "this" {
  for_each = { for k, v in var.dns_firewall_rule_group_associations : k => v if var.create && var.enable_dns_firewall }

  name   = try(each.value.name, "${var.name}-${each.key}")
  vpc_id = aws_vpc.this[0].id

  firewall_rule_group_id = each.value.firewall_rule_group_id
  mutation_protection    = try(each.value.mutation_protection, null)
  priority               = each.value.priority

  tags = merge(var.tags, try(each.value.tags, {}))
}

################################################################################
# Network Firewall
################################################################################

resource "aws_networkfirewall_firewall" "this" {
  count = var.create && var.create_network_firewall ? 1 : 0

  name              = coalesce(var.network_firewall_name, var.name)
  description       = var.network_firewall_description
  delete_protection = var.network_firewall_delete_protection

  firewall_policy_arn               = var.network_firewall_policy_arn
  firewall_policy_change_protection = var.network_firewall_policy_change_protection

  vpc_id                   = aws_vpc.this[0].id
  subnet_change_protection = var.network_firewall_subnet_change_protection

  dynamic "subnet_mapping" {
    for_each = toset(var.network_firewall_subnets)
    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = merge(var.tags, var.network_firewall_tags)
}

################################################################################
# Firewall Logging Configuration
################################################################################

resource "aws_networkfirewall_logging_configuration" "this" {
  count = var.create && var.create_network_firewall && var.create_network_firewall_logging_configuration ? 1 : 0

  firewall_arn = aws_networkfirewall_firewall.this[0].arn

  logging_configuration {
    # At least one config, at most, only two blocks can be specified; one for `FLOW` logs and one for `ALERT` logs.
    dynamic "log_destination_config" {
      for_each = var.network_firewall_logging_configuration_destination_config
      content {
        log_destination      = log_destination_config.value.log_destination
        log_destination_type = log_destination_config.value.log_destination_type
        log_type             = log_destination_config.value.log_type
      }
    }
  }
}

################################################################################
# DHCP Options Set
################################################################################

resource "aws_vpc_dhcp_options" "this" {
  count = var.create && var.create_dhcp_options ? 1 : 0

  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = merge(
    var.tags,
    { Name = var.name },
    var.dhcp_options_tags,
  )
}

resource "aws_vpc_dhcp_options_association" "this" {
  count = var.create && var.create_dhcp_options ? 1 : 0

  vpc_id          = aws_vpc.this[0].id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  count = var.create && var.create_internet_gateway ? 1 : 0

  tags = merge(
    var.tags,
    { Name = var.name },
    var.internet_gateway_tags,
  )
}

resource "aws_internet_gateway_attachment" "this" {
  count = var.create && var.attach_internet_gateway ? 1 : 0

  vpc_id              = local.vpc_id
  internet_gateway_id = var.create_internet_gateway ? aws_internet_gateway.this[0].id : var.internet_gateway_id
}

resource "aws_egress_only_internet_gateway" "this" {
  count = var.create && var.create_egress_only_internet_gateway ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    var.tags,
    { Name = var.name },
    var.internet_gateway_tags,
  )
}

################################################################################
# Customer Gateway(s)
################################################################################

resource "aws_customer_gateway" "this" {
  for_each = { for k, v in var.customer_gateways : k => v if var.create }

  bgp_asn    = each.value.bgp_asn
  ip_address = each.value.ip_address
  type       = try(each.value.type, "ipsec.1") # required but only one value accepted currently

  certificate_arn = try(each.value.certificate_arn, null)
  device_name     = try(each.value.device_name, null)

  tags = merge(
    var.tags,
    { Name = "${var.name}-${each.key}" },
    var.customer_gateway_tags,
  )
}

################################################################################
# VPN Gateway(s)
################################################################################

resource "aws_vpn_gateway" "this" {
  for_each = { for k, v in var.vpn_gateways : k => v if var.create }

  vpc_id            = local.vpc_id
  amazon_side_asn   = try(each.value.vpn_gateway_amazon_side_asn, null)
  availability_zone = try(each.value.availability_zone, null)

  tags = merge(
    var.tags,
    { Name = "${var.name}-${each.key}" },
    var.vpn_gateway_tags,
  )
}

################################################################################
# Default Security Group for VPC created
################################################################################

resource "aws_default_security_group" "this" {
  count = var.create && var.manage_default_security_group ? 1 : 0

  vpc_id = local.vpc_id

  dynamic "ingress" {
    for_each = var.default_security_group_ingress_rules
    content {
      self             = try(ingress.value.self, null)
      cidr_blocks      = try(ingress.value.ipv4_cidr_blocks, null)
      ipv6_cidr_blocks = try(ingress.value.ipv6_cidr_blocks, null)
      prefix_list_ids  = try(ingress.value.prefix_list_ids, null)
      security_groups  = try(ingress.value.security_groups, null)
      description      = try(ingress.value.description, null)
      from_port        = try(ingress.value.from_port, null)
      to_port          = try(ingress.value.to_port, null)
      protocol         = try(ingress.value.protocol, null)
    }
  }

  dynamic "egress" {
    for_each = var.default_security_group_egress_rules
    content {
      self             = try(egress.value.self, null)
      cidr_blocks      = try(egress.value.ipv4_cidr_blocks, null)
      ipv6_cidr_blocks = try(egress.value.ipv6_cidr_blocks, null)
      prefix_list_ids  = try(egress.value.prefix_list_ids, null)
      security_groups  = try(egress.value.security_groups, null)
      description      = try(egress.value.description, null)
      from_port        = try(egress.value.from_port, null)
      to_port          = try(egress.value.to_port, null)
      protocol         = try(egress.value.protocol, null)
    }
  }

  tags = merge(
    var.tags,
    { Name = "${var.name}-default" },
    var.default_security_group_tags,
  )
}

################################################################################
# Default Network ACL for VPC created
################################################################################

resource "aws_default_network_acl" "this" {
  count = var.create && var.manage_default_network_acl ? 1 : 0

  default_network_acl_id = try(aws_vpc.this[0].default_network_acl_id, null)

  tags = merge(
    var.tags,
    { Name = "${var.name}-default" },
    var.default_network_acl_tags,
  )

  lifecycle {
    ignore_changes = [
      # Ignore subnets that are dynamically added/removed here
      # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl#managing-subnets-in-a-default-network-acl
      subnet_ids,
      # Ignore ingress/egress since those are controlled below
      ingress,
      egress,
    ]
  }
}

resource "aws_network_acl_rule" "default_ingress" {
  for_each = { for k, v in var.default_network_acl_ingress_rules : k => v if var.create && var.manage_default_network_acl }

  network_acl_id = aws_default_network_acl.this[0].id

  rule_number     = each.key
  egress          = false
  protocol        = each.value.protocol
  rule_action     = each.value.rule_action
  cidr_block      = try(each.value.ipv4_cidr_block, null)
  ipv6_cidr_block = try(each.value.ipv6_cidr_block, null)
  from_port       = try(each.value.from_port, null)
  to_port         = try(each.value.to_port, null)
  icmp_type       = try(each.value.icmp_type, null)
  icmp_code       = try(each.value.icmp_code, null)
}

resource "aws_network_acl_rule" "default_egress" {
  for_each = { for k, v in var.default_network_acl_egress_rules : k => v if var.create && var.manage_default_network_acl }

  network_acl_id = aws_default_network_acl.this[0].id

  rule_number     = each.key
  egress          = true
  protocol        = each.value.protocol
  rule_action     = each.value.rule_action
  cidr_block      = try(each.value.ipv4_cidr_block, null)
  ipv6_cidr_block = try(each.value.ipv6_cidr_block, null)
  from_port       = try(each.value.from_port, null)
  to_port         = try(each.value.to_port, null)
  icmp_type       = try(each.value.icmp_type, null)
  icmp_code       = try(each.value.icmp_code, null)
}

################################################################################
# Default Route Table for VPC created
################################################################################

resource "aws_default_route_table" "this" {
  count = var.create && var.manage_default_route_table ? 1 : 0

  default_route_table_id = aws_vpc.this[0].default_route_table_id
  propagating_vgws       = var.default_route_table_propagating_vgws

  dynamic "timeouts" {
    for_each = var.default_route_table_timeouts
    content {
      create = try(each.value.create, null)
      update = try(each.value.update, null)
    }
  }

  tags = merge(
    var.tags,
    { Name = "${var.name}-default" },
    var.default_route_table_tags,
  )

  lifecycle {
    ignore_changes = [
      # Ignore route since that is controlled below
      route,
    ]
  }
}

resource "aws_route" "default" {
  for_each = { for k, v in var.default_route_table_routes : k => v if var.create && var.manage_default_route_table }

  route_table_id = aws_default_route_table.this[0].id

  destination_cidr_block      = try(each.value.destination_ipv4_cidr_block, null)
  destination_ipv6_cidr_block = try(each.value.destination_ipv6_cidr_block, null)
  destination_prefix_list_id  = try(each.value.destination_prefix_list_id, null)

  # One of the following target arguments must be supplied:
  carrier_gateway_id        = try(each.value.carrier_gateway_id, null)
  egress_only_gateway_id    = try(each.value.egress_only_gateway_id, null)
  gateway_id                = try(each.value.gateway_id, null)
  nat_gateway_id            = try(each.value.nat_gateway_id, null)
  local_gateway_id          = try(each.value.local_gateway_id, null)
  network_interface_id      = try(each.value.network_interface_id, null)
  transit_gateway_id        = try(each.value.transit_gateway_id, null)
  vpc_endpoint_id           = try(each.value.vpc_endpoint_id, null)
  vpc_peering_connection_id = try(each.value.vpc_peering_connection_id, null)

  timeouts {
    create = try(each.value.timeouts.create, null)
    update = try(each.value.timeouts.update, null)
    delete = try(each.value.timeouts.delete, null)
  }
}

################################################################################
# Account Default VPC
################################################################################

resource "aws_default_vpc" "this" {
  count = var.create && var.manage_default_vpc ? 1 : 0

  enable_dns_support   = var.default_vpc_enable_dns_support
  enable_dns_hostnames = var.default_vpc_enable_dns_hostnames
  enable_classiclink   = var.default_vpc_enable_classiclink

  tags = merge(
    var.tags,
    { Name = "default" },
    var.default_vpc_tags,
  )
}

################################################################################
# Account Default DHCP Options
################################################################################

resource "aws_default_vpc_dhcp_options" "this" {
  count = var.create && var.manage_default_dhcp_options ? 1 : 0

  netbios_name_servers = var.default_dhcp_options_netbios_name_servers
  netbios_node_type    = var.default_dhcp_options_netbios_node_type
  owner_id             = var.default_dhcp_options_owner_id

  tags = merge(
    var.tags,
    { Name = "${var.name}-default" },
    var.default_dhcp_options_tags,
  )
}
