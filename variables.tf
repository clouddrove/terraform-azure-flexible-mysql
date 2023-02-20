#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "repository" {
  type        = string
  default     = ""
  description = "Terraform current module repo"
}

variable "label_order" {
  type        = list(any)
  default     = []
  description = "Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] ."
}

variable "managedby" {
  type        = string
  default     = ""
  description = "ManagedBy, eg ''."
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = ""
}



variable "enabled" {
  type        = bool
  description = "Set to false to prevent the module from creating any resources."
  default     = true
}

variable "existing_private_dns_zone" {
  type        = bool
  description = "Name of the existing private DNS zone"
  default     = false
}

variable "enable_private_endpoint" {
  description = "Manages a Private Endpoint to Azure database for MySQL"
  default     = false
}

variable "registration_enabled" {
  type        = bool
  description = "Is auto-registration of virtual machine records in the virtual network in the Private DNS zone enabled"
  default     = false
}
###########azurerm_mysql_flexible_server######

variable "admin_username" {
  description = "The administrator login name for the new SQL Server"
  default     = null
}

variable "mysql_server_name" {
  type    = string
  default = ""
}
variable "admin_password" {
  type        = string
  description = "The password associated with the admin_username user"
  default     = null
}

variable "backup_retention_days" {
  type        = number
  default     = 7
  description = "The backup retention days for the MySQL Flexible Server. Possible values are between 1 and 35 days. Defaults to 7"
}

variable "delegated_subnet_id" {
  description = "The resource ID of the subnet"
  type        = string
  default     = ""
}

variable "sku_name" {
  type        = string
  default     = "GP_Standard_D8ds_v4"
  description = " The SKU Name for the MySQL Flexible Server."
}

variable "create_mode" {
  type        = string
  description = "The creation mode. Can be used to restore or replicate existing servers. Possible values are `Default`, `Replica`, `GeoRestore`, and `PointInTimeRestore`. Defaults to `Default`"
  default     = "Default"
}

variable "geo_redundant_backup_enabled" {
  type        = bool
  default     = false
  description = "Should geo redundant backup enabled? Defaults to false. Changing this forces a new MySQL Flexible Server to be created."
}

variable "replication_role" {
  type        = string
  default     = null
  description = "The replication role. Possible value is None."
}

variable "mysql_version" {
  type        = string
  default     = "5.7"
  description = "The version of the MySQL Flexible Server to use. Possible values are 5.7, and 8.0.21. Changing this forces a new MySQL Flexible Server to be created."
}

variable "zone" {
  type        = number
  default     = null
  description = "Specifies the Availability Zone in which this MySQL Flexible Server should be located. Possible values are 1, 2 and 3."
}

variable "point_in_time_restore_time_in_utc" {
  type        = string
  default     = null
  description = " The point in time to restore from creation_source_server_id when create_mode is PointInTimeRestore. Changing this forces a new MySQL Flexible Server to be created."
}

variable "source_server_id" {
  type        = string
  default     = null
  description = "The resource ID of the source MySQL Flexible Server to be restored. Required when create_mode is PointInTimeRestore, GeoRestore, and Replica. Changing this forces a new MySQL Flexible Server to be created."
}

variable "start_ip_address" {
  type    = string
  default = ""
}

variable "end_ip_address" {
  type    = string
  default = ""
}

variable "virtual_network_id" {
  type        = string
  description = "The name of the virtual network"
  default     = ""
}

variable "key_vault_key_id" {
  type        = string
  description = "The URL to a Key Vault Key"
  default     = null
}

variable "key_vault_id" {
  type        = string
  default     = ""
  description = "Specifies the URL to a Key Vault Key (either from a Key Vault Key, or the Key URL for the Key Vault Secret"
}


variable "private_dns" {
  type    = bool
  default = false
}

variable "main_rg_name" {
  type    = string
  default = ""
}
variable "location" {
  type        = string
  default     = ""
  description = "The Azure Region where the MySQL Flexible Server should exist. Changing this forces a new MySQL Flexible Server to be created."
}

variable "existing_private_dns_zone_id" {
  type    = string
  default = ""
}
variable "existing_private_dns_zone_name" {
  type        = string
  default     = ""
  description = " The name of the Private DNS zone (without a terminating dot). Changing this forces a new resource to be created."
}

variable "auto_grow_enabled" {
  type        = bool
  default     = false
  description = "Should Storage Auto Grow be enabled? Defaults to true."
}
variable "iops" {
  type        = number
  default     = 360
  description = "The storage IOPS for the MySQL Flexible Server. Possible values are between 360 and 20000."
}

variable "size_gb" {
  type        = string
  default     = "20"
  description = "The max storage allowed for the MySQL Flexible Server. Possible values are between 20 and 16384."
}
variable "db_name" {
  type        = string
  default     = ""
  description = "Specifies the name of the MySQL Database, which needs to be a valid MySQL identifier. Changing this forces a new resource to be created."
}

variable "charset" {
  type        = string
  default     = ""
  description = "Specifies the Charset for the MySQL Database, which needs to be a valid MySQL Charset. Changing this forces a new resource to be created."
}
variable "collation" {
  type        = string
  default     = ""
  description = "Specifies the Collation for the MySQL Database, which needs to be a valid MySQL Collation. Changing this forces a new resource to be created."
}
variable "server_configuration_names" {
  type        = list(string)
  default     = []
  description = "Specifies the name of the MySQL Flexible Server Configuration, which needs to be a valid MySQL configuration name. Changing this forces a new resource to be created."
}

variable "values" {
  type        = list(string)
  default     = []
  description = "Specifies the value of the MySQL Flexible Server Configuration. See the MySQL documentation for valid values. Changing this forces a new resource to be created."
}
