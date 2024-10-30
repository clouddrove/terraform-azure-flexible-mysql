## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_password | The password associated with the admin\_username user | `string` | `null` | no |
| admin\_password\_length | Length of random password generated. | `number` | `16` | no |
| admin\_username | The administrator login name for the new SQL Server | `any` | `null` | no |
| auto\_grow\_enabled | Should Storage Auto Grow be enabled? Defaults to true. | `bool` | `false` | no |
| backup\_retention\_days | The backup retention days for the MySQL Flexible Server. Possible values are between 1 and 35 days. Defaults to 7 | `number` | `7` | no |
| charset | Specifies the Charset for the MySQL Database, which needs to be a valid MySQL Charset. Changing this forces a new resource to be created. | `string` | `""` | no |
| collation | Specifies the Collation for the MySQL Database, which needs to be a valid MySQL Collation. Changing this forces a new resource to be created. | `string` | `""` | no |
| create\_mode | The creation mode. Can be used to restore or replicate existing servers. Possible values are `Default`, `Replica`, `GeoRestore`, and `PointInTimeRestore`. Defaults to `Default` | `string` | `"Default"` | no |
| custom\_tags | n/a | `map(string)` | `{}` | no |
| db\_name | Specifies the name of the MySQL Database, which needs to be a valid MySQL identifier. Changing this forces a new resource to be created. | `string` | `""` | no |
| delegated\_subnet\_id | The resource ID of the subnet | `string` | `""` | no |
| enable\_diagnostic | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| enable\_private\_endpoint | Manages a Private Endpoint to Azure database for MySQL | `bool` | `false` | no |
| enabled | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| end\_ip\_address | n/a | `string` | `""` | no |
| entra\_authentication | Azure Entra authentication configuration block for Azure MySQL Flexible Server | <pre>object({<br>    user_assigned_identity_id = optional(string, null)<br>    login                     = optional(string, null)<br>    object_id                 = optional(string, null)<br>  })</pre> | `{}` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| eventhub\_authorization\_rule\_id | Eventhub authorization rule id to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| eventhub\_name | Eventhub Name to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| existing\_private\_dns\_zone | Name of the existing private DNS zone | `bool` | `false` | no |
| existing\_private\_dns\_zone\_id | n/a | `string` | `""` | no |
| existing\_private\_dns\_zone\_name | The name of the Private DNS zone (without a terminating dot). Changing this forces a new resource to be created. | `string` | `""` | no |
| geo\_redundant\_backup\_enabled | Should geo redundant backup enabled? Defaults to false. Changing this forces a new MySQL Flexible Server to be created. | `bool` | `true` | no |
| high\_availability | Map of high availability configuration: https://docs.microsoft.com/en-us/azure/mysql/flexible-server/concepts-high-availability. `null` to disable high availability | <pre>object({<br>    mode                      = string<br>    standby_availability_zone = optional(number)<br>  })</pre> | `null` | no |
| identity\_type | Type of managed identity to set | `string` | `null` | no |
| iops | The storage IOPS for the MySQL Flexible Server. Possible values are between 360 and 20000. | `number` | `360` | no |
| key\_vault\_id | Specifies the URL to a Key Vault Key (either from a Key Vault Key, or the Key URL for the Key Vault Secret | `string` | `""` | no |
| key\_vault\_key\_id | The URL to a Key Vault Key | `string` | `null` | no |
| label\_order | Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] . | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| location | The Azure Region where the MySQL Flexible Server should exist. Changing this forces a new MySQL Flexible Server to be created. | `string` | `""` | no |
| log\_analytics\_destination\_type | Possible values are AzureDiagnostics and Dedicated, default to AzureDiagnostics. When set to Dedicated, logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy AzureDiagnostics table. | `string` | `"AzureDiagnostics"` | no |
| log\_analytics\_workspace\_id | Log Analytics workspace id in which logs should be retained. | `string` | `null` | no |
| log\_category | Categories of logs to be recorded in diagnostic setting. Acceptable values are MySqlSlowLogs , MySqlAuditLogs | `list(string)` | <pre>[<br>  "MySqlAuditLogs"<br>]</pre> | no |
| main\_rg\_name | n/a | `string` | `""` | no |
| managedby | ManagedBy, eg ''. | `string` | `""` | no |
| metric\_enabled | Whether metric diagnonsis should be enable in diagnostic settings for flexible Mysql. | `bool` | `true` | no |
| mysql\_server\_name | n/a | `string` | `""` | no |
| mysql\_version | The version of the MySQL Flexible Server to use. Possible values are 5.7, and 8.0.21. Changing this forces a new MySQL Flexible Server to be created. | `string` | `"5.7"` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| point\_in\_time\_restore\_time\_in\_utc | The point in time to restore from creation\_source\_server\_id when create\_mode is PointInTimeRestore. Changing this forces a new MySQL Flexible Server to be created. | `string` | `null` | no |
| private\_dns | n/a | `bool` | `false` | no |
| registration\_enabled | Is auto-registration of virtual machine records in the virtual network in the Private DNS zone enabled | `bool` | `false` | no |
| replication\_role | The replication role. Possible value is None. | `string` | `null` | no |
| repository | Terraform current module repo | `string` | `""` | no |
| resource\_group\_name | A container that holds related resources for an Azure solution | `string` | `""` | no |
| server\_configuration\_names | Specifies the name of the MySQL Flexible Server Configuration, which needs to be a valid MySQL configuration name. Changing this forces a new resource to be created. | `list(string)` | `[]` | no |
| size\_gb | The max storage allowed for the MySQL Flexible Server. Possible values are between 20 and 16384. | `string` | `"20"` | no |
| sku\_name | The SKU Name for the MySQL Flexible Server. | `string` | `"GP_Standard_D8ds_v4"` | no |
| source\_server\_id | The resource ID of the source MySQL Flexible Server to be restored. Required when create\_mode is PointInTimeRestore, GeoRestore, and Replica. Changing this forces a new MySQL Flexible Server to be created. | `string` | `null` | no |
| start\_ip\_address | n/a | `string` | `""` | no |
| storage\_account\_id | Storage account id to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| user\_assigned\_identity\_ids | List of user-assigned managed identity IDs | `list(string)` | `[]` | no |
| values | Specifies the value of the MySQL Flexible Server Configuration. See the MySQL documentation for valid values. Changing this forces a new resource to be created. | `list(string)` | `[]` | no |
| virtual\_network\_id | The name of the virtual network | `string` | `""` | no |
| zone | Specifies the Availability Zone in which this MySQL Flexible Server should be located. Possible values are 1, 2 and 3. | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| azurerm\_mysql\_flexible\_server\_configuration\_id | The ID of the MySQL Flexible Server Configuration. |
| azurerm\_private\_dns\_zone\_id | The Private DNS Zone ID. |
| azurerm\_private\_dns\_zone\_virtual\_network\_link\_id | The ID of the Private DNS Zone Virtual Network Link. |
| existing\_private\_dns\_zone\_virtual\_network\_link\_id | The ID of the Private DNS Zone Virtual Network Link. |
| mysql\_flexible\_server\_id | The ID of the MySQL Flexible Server. |
| password\_result | Password Value |

