# AWS Network Firewall Terraform Module

Terraform module which creates AWS Network Firewall resources.

## Usage

See [`examples`](https://github.com/clowdhaus/terraform-aws-vpc-v4/tree/main/examples) directory for working examples to reference:

```hcl
module "network_firewall" {
  source = "terraform-aws-modules/vpc/aws//modules/network-firewall"

  name        = "Example"
  description = "Example network firewall"

  vpc_id         = "vpc-12345678"
  subnet_mapping = ["subnet-12345678", "subnet-87654321"]

  # Policy
  policy_description = "Example network firewall policy"
  policy_stateful_rule_group_reference = [
    { rule_group_key = "stateful_ex1" },
    { rule_group_key = "stateful_ex2" },
    { rule_group_key = "stateful_ex3" },
    { rule_group_key = "stateful_ex4" },
  ]

  policy_stateless_default_actions          = ["aws:pass"]
  policy_stateless_fragment_default_actions = ["aws:drop"]
  policy_stateless_rule_group_reference = [
    {
      priority       = 1
      rule_group_key = "stateless_ex1"
    },
  ]

  # Rule Group(s)
  rule_groups = {

    stateful_ex1 = {
      name        = "Example-stateful-ex1"
      description = "Stateful Inspection for denying access to a domain"
      type        = "STATEFUL"
      capacity    = 100

      rule_group = {
        rules_source = {
          rules_source_list = {
            generated_rules_type = "DENYLIST"
            target_types         = ["HTTP_HOST"]
            targets              = ["test.example.com"]
          }
        }
      }

      # Resource Policy - Rule Group
      create_resource_policy     = true
      attach_resource_policy     = true
      resource_policy_principals = ["arn:aws:iam::123456789012:root"]
    }

    stateful_ex2 = {
      name        = "Example-stateful-ex2"
      description = "Stateful Inspection for permitting packets from a source IP address"
      type        = "STATEFUL"
      capacity    = 50

      rule_group = {
        rules_source = {
          stateful_rule = [{
            action = "PASS"
            header = {
              destination      = "ANY"
              destination_port = "ANY"
              protocol         = "HTTP"
              direction        = "ANY"
              source_port      = "ANY"
              source           = "1.2.3.4"
            }
            rule_option = [{
              keyword = "sid:1"
            }]
          }]
        }
      }
    }

    stateful_ex3 = {
      name        = "Example-stateful-ex3"
      description = "Stateful Inspection for blocking packets from going to an intended destination"
      type        = "STATEFUL"
      capacity    = 100

      rule_group = {
        rules_source = {
          stateful_rule = [{
            action = "DROP"
            header = {
              destination      = "124.1.1.24/32"
              destination_port = 53
              direction        = "ANY"
              protocol         = "TCP"
              source           = "1.2.3.4/32"
              source_port      = 53
            }
            rule_option = [{
              keyword = "sid:1"
            }]
          }]
        }
      }
    }

    stateful_ex4 = {
      name        = "Example-stateful-ex4"
      description = "Stateful Inspection from rule group specifications using rule variables and Suricata format rules"
      type        = "STATEFUL"
      capacity    = 100

      rule_group = {
        rule_variables = {
          ip_sets = [{
            key = "WEBSERVERS_HOSTS"
            ip_set = {
              definition = ["10.0.0.0/16", "10.0.1.0/24", "192.168.0.0/16"]
            }
            }, {
            key = "EXTERNAL_HOST"
            ip_set = {
              definition = ["1.2.3.4/32"]
            }
          }]
          port_sets = [{
            key = "HTTP_PORTS"
            port_set = {
              definition = ["443", "80"]
            }
          }]
        }
        rules_source = {
          rules_string = <<-EOT
          alert icmp any any -> any any (msg: "Allowing ICMP packets"; sid:1; rev:1;)
          pass icmp any any -> any any (msg: "Allowing ICMP packets"; sid:2; rev:1;)
          EOT
        }
      }
    }

    stateless_ex1 = {
      name        = "Example-stateless-ex1"
      description = "Stateless Inspection with a Custom Action"
      type        = "STATELESS"
      capacity    = 100

      rule_group = {
        rules_source = {
          stateless_rules_and_custom_actions = {
            custom_action = [{
              action_definition = {
                publish_metric_action = {
                  dimension = [{
                    value = "2"
                  }]
                }
              }
              action_name = "ExampleMetricsAction"
            }]
            stateless_rule = [{
              priority = 1
              rule_definition = {
                actions = ["aws:pass", "ExampleMetricsAction"]
                match_attributes = {
                  source = [{
                    address_definition = "1.2.3.4/32"
                  }]
                  source_port = [{
                    from_port = 443
                    to_port   = 443
                  }]
                  destination = [{
                    address_definition = "124.1.1.5/32"
                  }]
                  destination_port = [{
                    from_port = 443
                    to_port   = 443
                  }]
                  protocols = [6]
                  tcp_flag = [{
                    flags = ["SYN"]
                    masks = ["SYN", "ACK"]
                  }]
                }
              }
            }]
          }
        }
      }

      # Resource Policy - Rule Group
      create_resource_policy     = true
      attach_resource_policy     = true
      resource_policy_principals = ["arn:aws:iam::123456789012:root"]
    }
  }

  # Resource Policy - Firewall Policy
  create_firewall_policy_resource_policy     = true
  attach_firewall_policy_resource_policy     = true
  firewall_policy_resource_policy_principals = ["arn:aws:iam::123456789012:root"]

  # Logging configuration
  create_logging_configuration = true
  logging_configuration_destination_config = [
    {
      log_destination = {
        logGroup = "/aws/networkfirewall/Example"
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    },
    {
      log_destination = {
        bucketName = "network-firewall-example-logs"
        prefix     = local.name
      }
      log_destination_type = "S3"
      log_type             = "FLOW"
    }
  ]

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_networkfirewall_firewall_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_resource_policy.firewall_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_resource_policy) | resource |
| [aws_networkfirewall_resource_policy.rule_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_resource_policy) | resource |
| [aws_networkfirewall_rule_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_ram_resource_association.firewall_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_association.rule_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_iam_policy_document.firewall_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.rule_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attach_firewall_policy_resource_policy"></a> [attach\_firewall\_policy\_resource\_policy](#input\_attach\_firewall\_policy\_resource\_policy) | Controls if a Resource Policy should be attached to the Firewall Policy | `bool` | `false` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if Network Firewall resources should be created | `bool` | `true` | no |
| <a name="input_create_firewall_policy"></a> [create\_firewall\_policy](#input\_create\_firewall\_policy) | Controls if a Firewall Policy should be created | `bool` | `true` | no |
| <a name="input_create_firewall_policy_resource_policy"></a> [create\_firewall\_policy\_resource\_policy](#input\_create\_firewall\_policy\_resource\_policy) | Controls if a Firewall Policy Resource Policy should be created | `bool` | `false` | no |
| <a name="input_create_logging_configuration"></a> [create\_logging\_configuration](#input\_create\_logging\_configuration) | Controls if a Logging Configuration should be created | `bool` | `false` | no |
| <a name="input_create_rule_groups"></a> [create\_rule\_groups](#input\_create\_rule\_groups) | Controls if Firewall Rule Groups should be created | `bool` | `true` | no |
| <a name="input_delete_protection"></a> [delete\_protection](#input\_delete\_protection) | A boolean flag indicating whether it is possible to delete the firewall. Defaults to `true` | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the Network Firewall | `string` | `""` | no |
| <a name="input_firewall_policy_arn"></a> [firewall\_policy\_arn](#input\_firewall\_policy\_arn) | The ARN of the Firewall Policy to use; required when `create_firewall_policy` is `false` | `string` | `""` | no |
| <a name="input_firewall_policy_change_protection"></a> [firewall\_policy\_change\_protection](#input\_firewall\_policy\_change\_protection) | A boolean flag indicating whether it is possible to change the associated firewall policy. Defaults to `false` | `bool` | `null` | no |
| <a name="input_firewall_policy_ram_resource_associations"></a> [firewall\_policy\_ram\_resource\_associations](#input\_firewall\_policy\_ram\_resource\_associations) | A map of RAM resource associations for the created firewall policy | `map(string)` | `{}` | no |
| <a name="input_firewall_policy_resource_policy"></a> [firewall\_policy\_resource\_policy](#input\_firewall\_policy\_resource\_policy) | The policy JSON to use for the Firewall Policy Resource Policy; required when `create_firewall_policy_resource_policy` is `false` | `string` | `""` | no |
| <a name="input_firewall_policy_resource_policy_actions"></a> [firewall\_policy\_resource\_policy\_actions](#input\_firewall\_policy\_resource\_policy\_actions) | A list of IAM actions allowed in the Firewall Policy Resource Policy | `list(string)` | <pre>[<br>  "network-firewall:ListFirewallPolicies",<br>  "network-firewall:CreateFirewall",<br>  "network-firewall:UpdateFirewall",<br>  "network-firewall:AssociateFirewallPolicy"<br>]</pre> | no |
| <a name="input_firewall_policy_resource_policy_principals"></a> [firewall\_policy\_resource\_policy\_principals](#input\_firewall\_policy\_resource\_policy\_principals) | A list of IAM principals allowed in the Firewall Policy Resource Policy | `list(string)` | `[]` | no |
| <a name="input_logging_configuration_destination_config"></a> [logging\_configuration\_destination\_config](#input\_logging\_configuration\_destination\_config) | A list of min 1, max 2 configuration blocks describing the destination for the logging configuration | `any` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Network Firewall | `string` | `""` | no |
| <a name="input_policy_description"></a> [policy\_description](#input\_policy\_description) | A friendly description of the firewall policy | `string` | `null` | no |
| <a name="input_policy_stateful_default_actions"></a> [policy\_stateful\_default\_actions](#input\_policy\_stateful\_default\_actions) | Set of actions to take on a packet if it does not match any stateful rules in the policy. This can only be specified if the policy has a `stateful_engine_options` block with a rule\_order value of `STRICT_ORDER`. You can specify one of either or neither values of `aws:drop_strict` or `aws:drop_established`, as well as any combination of `aws:alert_strict` and `aws:alert_established` | `list(string)` | `[]` | no |
| <a name="input_policy_stateful_engine_options"></a> [policy\_stateful\_engine\_options](#input\_policy\_stateful\_engine\_options) | A configuration block that defines options on how the policy handles stateful rules. See [Stateful Engine Options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy#stateful-engine-options) for details | `any` | `{}` | no |
| <a name="input_policy_stateful_rule_group_reference"></a> [policy\_stateful\_rule\_group\_reference](#input\_policy\_stateful\_rule\_group\_reference) | Set of configuration blocks containing references to the stateful rule groups that are used in the policy. See [Stateful Rule Group Reference](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy#stateful-rule-group-reference) for details | `any` | `{}` | no |
| <a name="input_policy_stateless_custom_action"></a> [policy\_stateless\_custom\_action](#input\_policy\_stateless\_custom\_action) | Set of configuration blocks describing the custom action definitions that are available for use in the firewall policy's `stateless_default_actions` | `any` | `{}` | no |
| <a name="input_policy_stateless_default_actions"></a> [policy\_stateless\_default\_actions](#input\_policy\_stateless\_default\_actions) | Set of actions to take on a packet if it does not match any of the stateless rules in the policy. You must specify one of the standard actions including: `aws:drop`, `aws:pass`, or `aws:forward_to_sfe` | `list(string)` | <pre>[<br>  "aws:pass"<br>]</pre> | no |
| <a name="input_policy_stateless_fragment_default_actions"></a> [policy\_stateless\_fragment\_default\_actions](#input\_policy\_stateless\_fragment\_default\_actions) | Set of actions to take on a fragmented packet if it does not match any of the stateless rules in the policy. You must specify one of the standard actions including: `aws:drop`, `aws:pass`, or `aws:forward_to_sfe` | `list(string)` | <pre>[<br>  "aws:pass"<br>]</pre> | no |
| <a name="input_policy_stateless_rule_group_reference"></a> [policy\_stateless\_rule\_group\_reference](#input\_policy\_stateless\_rule\_group\_reference) | Set of configuration blocks containing references to the stateless rule groups that are used in the policy. See [Stateless Rule Group Reference](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy#stateless-rule-group-reference) for details | `any` | `{}` | no |
| <a name="input_rule_groups"></a> [rule\_groups](#input\_rule\_groups) | A map of Firewall Rule Group definitions to be created | `any` | `{}` | no |
| <a name="input_rule_groups_ram_resource_associations"></a> [rule\_groups\_ram\_resource\_associations](#input\_rule\_groups\_ram\_resource\_associations) | A map of RAM resource associations for the created Firewall Rule Groups | `map(string)` | `{}` | no |
| <a name="input_subnet_change_protection"></a> [subnet\_change\_protection](#input\_subnet\_change\_protection) | A boolean flag indicating whether it is possible to change the associated subnet(s). Defaults to `true` | `bool` | `true` | no |
| <a name="input_subnet_mapping"></a> [subnet\_mapping](#input\_subnet\_mapping) | Set of configuration blocks describing the public subnets. Each subnet must belong to a different Availability Zone in the VPC. AWS Network Firewall creates a firewall endpoint in each subnet | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The unique identifier of the VPC where AWS Network Firewall should create the firewall | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) that identifies the firewall |
| <a name="output_firewall_policy_resource_policy_id"></a> [firewall\_policy\_resource\_policy\_id](#output\_firewall\_policy\_resource\_policy\_id) | The Amazon Resource Name (ARN) of the firewall policy associated with the resource policy |
| <a name="output_id"></a> [id](#output\_id) | The Amazon Resource Name (ARN) that identifies the firewall |
| <a name="output_logging_configuration_id"></a> [logging\_configuration\_id](#output\_logging\_configuration\_id) | The Amazon Resource Name (ARN) of the associated firewall |
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | The Amazon Resource Name (ARN) that identifies the firewall policy |
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | The Amazon Resource Name (ARN) that identifies the firewall policy |
| <a name="output_policy_update_token"></a> [policy\_update\_token](#output\_policy\_update\_token) | A string token used when updating a firewall policy |
| <a name="output_rule_group_resource_policies"></a> [rule\_group\_resource\_policies](#output\_rule\_group\_resource\_policies) | Map of Rule Group resource policies created and their attributes |
| <a name="output_rule_groups"></a> [rule\_groups](#output\_rule\_groups) | A map of the rule groups created and their attributes |
| <a name="output_status"></a> [status](#output\_status) | Nested list of information about the current status of the firewall |
| <a name="output_update_token"></a> [update\_token](#output\_update\_token) | A string token used when updating a firewall |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/clowdhaus/terraform-aws-vpc-v4/blob/main/LICENSE).
