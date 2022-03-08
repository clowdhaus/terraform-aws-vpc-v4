# Complete AWS VPC Example

Configuration in this directory creates:

- <TODO>

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which will incur monetary charges on your AWS bill. Run `terraform destroy` when you no longer need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network_firewall"></a> [network\_firewall](#module\_network\_firewall) | ../../modules/network-firewall | n/a |
| <a name="module_public_subnets"></a> [public\_subnets](#module\_public\_subnets) | ../../modules/subnets | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_s3_bucket.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Amazon Resource Name (ARN) of VPC |
| <a name="output_cidr_block"></a> [cidr\_block](#output\_cidr\_block) | The IPv4 CIDR block of the VPC |
| <a name="output_customer_gateways"></a> [customer\_gateways](#output\_customer\_gateways) | Map of Customer Gateways and their attributes |
| <a name="output_default_dhcp_options_arn"></a> [default\_dhcp\_options\_arn](#output\_default\_dhcp\_options\_arn) | The ARN of the default DHCP options set |
| <a name="output_default_dhcp_options_id"></a> [default\_dhcp\_options\_id](#output\_default\_dhcp\_options\_id) | The ID of the default DHCP options set |
| <a name="output_default_network_acl_arn"></a> [default\_network\_acl\_arn](#output\_default\_network\_acl\_arn) | ARN of the Default Network ACL |
| <a name="output_default_network_acl_id"></a> [default\_network\_acl\_id](#output\_default\_network\_acl\_id) | ID of the Default Network ACL |
| <a name="output_default_route_table_arn"></a> [default\_route\_table\_arn](#output\_default\_route\_table\_arn) | ARN of the default route table |
| <a name="output_default_route_table_id"></a> [default\_route\_table\_id](#output\_default\_route\_table\_id) | ID of the default route table |
| <a name="output_default_security_group_arn"></a> [default\_security\_group\_arn](#output\_default\_security\_group\_arn) | The ARN of the security group created by default on VPC creation |
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | The ID of the security group created by default on VPC creation |
| <a name="output_default_vpc_arn"></a> [default\_vpc\_arn](#output\_default\_vpc\_arn) | The ARN of the Default VPC |
| <a name="output_default_vpc_cidr_block"></a> [default\_vpc\_cidr\_block](#output\_default\_vpc\_cidr\_block) | The CIDR block of the Default VPC |
| <a name="output_default_vpc_default_network_acl_id"></a> [default\_vpc\_default\_network\_acl\_id](#output\_default\_vpc\_default\_network\_acl\_id) | The ID of the default network ACL of the Default VPC |
| <a name="output_default_vpc_default_route_table_id"></a> [default\_vpc\_default\_route\_table\_id](#output\_default\_vpc\_default\_route\_table\_id) | The ID of the default route table of the Default VPC |
| <a name="output_default_vpc_default_security_group_id"></a> [default\_vpc\_default\_security\_group\_id](#output\_default\_vpc\_default\_security\_group\_id) | The ID of the security group created by default on Default VPC creation |
| <a name="output_default_vpc_enable_dns_hostnames"></a> [default\_vpc\_enable\_dns\_hostnames](#output\_default\_vpc\_enable\_dns\_hostnames) | Whether or not the Default VPC has DNS hostname support |
| <a name="output_default_vpc_enable_dns_support"></a> [default\_vpc\_enable\_dns\_support](#output\_default\_vpc\_enable\_dns\_support) | Whether or not the Default VPC has DNS support |
| <a name="output_default_vpc_id"></a> [default\_vpc\_id](#output\_default\_vpc\_id) | The ID of the Default VPC |
| <a name="output_default_vpc_instance_tenancy"></a> [default\_vpc\_instance\_tenancy](#output\_default\_vpc\_instance\_tenancy) | Tenancy of instances spin up within Default VPC |
| <a name="output_default_vpc_main_route_table_id"></a> [default\_vpc\_main\_route\_table\_id](#output\_default\_vpc\_main\_route\_table\_id) | The ID of the main route table associated with the Default VPC |
| <a name="output_dhcp_options_arn"></a> [dhcp\_options\_arn](#output\_dhcp\_options\_arn) | The ARN of the DHCP options set |
| <a name="output_dhcp_options_association_id"></a> [dhcp\_options\_association\_id](#output\_dhcp\_options\_association\_id) | The ID of the DHCP Options set association |
| <a name="output_dhcp_options_id"></a> [dhcp\_options\_id](#output\_dhcp\_options\_id) | The ID of the DHCP options set |
| <a name="output_egress_only_internet_gateway_id"></a> [egress\_only\_internet\_gateway\_id](#output\_egress\_only\_internet\_gateway\_id) | The ID of the Egress-Only Internet Gateway |
| <a name="output_flow_log_arn"></a> [flow\_log\_arn](#output\_flow\_log\_arn) | The VPC flow log ARN |
| <a name="output_flow_log_cloudwatch_log_group_arn"></a> [flow\_log\_cloudwatch\_log\_group\_arn](#output\_flow\_log\_cloudwatch\_log\_group\_arn) | ARN of cloudwatch log group created |
| <a name="output_flow_log_cloudwatch_log_group_name"></a> [flow\_log\_cloudwatch\_log\_group\_name](#output\_flow\_log\_cloudwatch\_log\_group\_name) | Name of cloudwatch log group created |
| <a name="output_flow_log_iam_role_arn"></a> [flow\_log\_iam\_role\_arn](#output\_flow\_log\_iam\_role\_arn) | ARN of the flow log CloudWatch IAM role |
| <a name="output_flow_log_iam_role_name"></a> [flow\_log\_iam\_role\_name](#output\_flow\_log\_iam\_role\_name) | Name of the flow log CloudWatch IAM role |
| <a name="output_flow_log_iam_role_unique_id"></a> [flow\_log\_iam\_role\_unique\_id](#output\_flow\_log\_iam\_role\_unique\_id) | Stable and unique string identifying the flow log CloudWatch IAM role |
| <a name="output_flow_log_id"></a> [flow\_log\_id](#output\_flow\_log\_id) | The VPC flow log ID |
| <a name="output_id"></a> [id](#output\_id) | The ID of the VPC |
| <a name="output_internet_gateway_arn"></a> [internet\_gateway\_arn](#output\_internet\_gateway\_arn) | The ARN of the Internet Gateway |
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | The ID of the Internet Gateway |
| <a name="output_ipv4_cidr_block_associations"></a> [ipv4\_cidr\_block\_associations](#output\_ipv4\_cidr\_block\_associations) | Map of IPv4 CIDR block associations and their attributes |
| <a name="output_ipv6_association_id"></a> [ipv6\_association\_id](#output\_ipv6\_association\_id) | The association ID for the IPv6 CIDR block |
| <a name="output_ipv6_cidr_block"></a> [ipv6\_cidr\_block](#output\_ipv6\_cidr\_block) | The IPv6 CIDR block of the VPC |
| <a name="output_ipv6_cidr_block_associations"></a> [ipv6\_cidr\_block\_associations](#output\_ipv6\_cidr\_block\_associations) | Map of IPv6 CIDR block associations and their attributes |
| <a name="output_ipv6_cidr_block_network_border_group"></a> [ipv6\_cidr\_block\_network\_border\_group](#output\_ipv6\_cidr\_block\_network\_border\_group) | The Network Border Group Zone name |
| <a name="output_main_route_table_id"></a> [main\_route\_table\_id](#output\_main\_route\_table\_id) | The ID of the main route table associated with this VPC. Note that you can change a VPC's main route table by using an `aws_main_route_table_association` |
| <a name="output_network_firewall_arn"></a> [network\_firewall\_arn](#output\_network\_firewall\_arn) | The Amazon Resource Name (ARN) that identifies the firewall |
| <a name="output_network_firewall_id"></a> [network\_firewall\_id](#output\_network\_firewall\_id) | The Amazon Resource Name (ARN) that identifies the firewall |
| <a name="output_network_firewall_logging_configuration_id"></a> [network\_firewall\_logging\_configuration\_id](#output\_network\_firewall\_logging\_configuration\_id) | The Amazon Resource Name (ARN) of the associated firewall |
| <a name="output_network_firewall_policy_arn"></a> [network\_firewall\_policy\_arn](#output\_network\_firewall\_policy\_arn) | The Amazon Resource Name (ARN) that identifies the firewall policy |
| <a name="output_network_firewall_policy_id"></a> [network\_firewall\_policy\_id](#output\_network\_firewall\_policy\_id) | The Amazon Resource Name (ARN) that identifies the firewall policy |
| <a name="output_network_firewall_policy_resource_policy_id"></a> [network\_firewall\_policy\_resource\_policy\_id](#output\_network\_firewall\_policy\_resource\_policy\_id) | The Amazon Resource Name (ARN) of the firewall policy associated with the resource policy |
| <a name="output_network_firewall_policy_update_token"></a> [network\_firewall\_policy\_update\_token](#output\_network\_firewall\_policy\_update\_token) | A string token used when updating a firewall policy |
| <a name="output_network_firewall_rule_group_resource_policies"></a> [network\_firewall\_rule\_group\_resource\_policies](#output\_network\_firewall\_rule\_group\_resource\_policies) | Map of Rule Group resource policies created and their attributes |
| <a name="output_network_firewall_rule_groups"></a> [network\_firewall\_rule\_groups](#output\_network\_firewall\_rule\_groups) | A map of the rule groups created and their attributes |
| <a name="output_network_firewall_status"></a> [network\_firewall\_status](#output\_network\_firewall\_status) | Nested list of information about the current status of the firewall |
| <a name="output_network_firewall_update_token"></a> [network\_firewall\_update\_token](#output\_network\_firewall\_update\_token) | A string token used when updating a firewall |
| <a name="output_public_subnet_arns"></a> [public\_subnet\_arns](#output\_public\_subnet\_arns) | List of subnet ARNs |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | List of subnet IDs |
| <a name="output_public_subnet_ipv4_cidr_blocks"></a> [public\_subnet\_ipv4\_cidr\_blocks](#output\_public\_subnet\_ipv4\_cidr\_blocks) | List of subnet IPv4 CIDR blocks |
| <a name="output_public_subnet_ipv6_cidr_blocks"></a> [public\_subnet\_ipv6\_cidr\_blocks](#output\_public\_subnet\_ipv6\_cidr\_blocks) | List of subnet IPv6 CIDR blocks |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | Map of public subnets created and their attributes |
| <a name="output_public_subnets_ec2_subnet_cidr_reservations"></a> [public\_subnets\_ec2\_subnet\_cidr\_reservations](#output\_public\_subnets\_ec2\_subnet\_cidr\_reservations) | Map of EC2 subnet CIDR reservations created and their attributes |
| <a name="output_public_subnets_network_acl_arn"></a> [public\_subnets\_network\_acl\_arn](#output\_public\_subnets\_network\_acl\_arn) | The ID of the network ACL |
| <a name="output_public_subnets_network_acl_id"></a> [public\_subnets\_network\_acl\_id](#output\_public\_subnets\_network\_acl\_id) | The ARN of the network ACL |
| <a name="output_public_subnets_network_acl_rules_egress"></a> [public\_subnets\_network\_acl\_rules\_egress](#output\_public\_subnets\_network\_acl\_rules\_egress) | Map of egress network ACL rules created and their attributes |
| <a name="output_public_subnets_network_acl_rules_ingress"></a> [public\_subnets\_network\_acl\_rules\_ingress](#output\_public\_subnets\_network\_acl\_rules\_ingress) | Map of ingress network ACL rules created and their attributes |
| <a name="output_public_subnets_route_table_gateway_association_ids"></a> [public\_subnets\_route\_table\_gateway\_association\_ids](#output\_public\_subnets\_route\_table\_gateway\_association\_ids) | List of subnet route table association IDs |
| <a name="output_public_subnets_route_table_ids"></a> [public\_subnets\_route\_table\_ids](#output\_public\_subnets\_route\_table\_ids) | List of route table IDs |
| <a name="output_public_subnets_route_table_subnet_association_ids"></a> [public\_subnets\_route\_table\_subnet\_association\_ids](#output\_public\_subnets\_route\_table\_subnet\_association\_ids) | List of subnet route table association IDs |
| <a name="output_public_subnets_route_tables"></a> [public\_subnets\_route\_tables](#output\_public\_subnets\_route\_tables) | Map of route tables created and their attributes |
| <a name="output_vpn_gateways"></a> [vpn\_gateways](#output\_vpn\_gateways) | Map of VPN Gateways and their attributes |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

Apache-2.0 Licensed. See [LICENSE](../../LICENSE).
