variable "project_id" {
  type    = "string"
  default = "jameswu0629"
}

variable "bucket_name" {
  type = "string"
  default = "jameswu0629-ndb-conf"
}

variable "zones" {
  type = "list"
  default = ["asia-east1-b", "asia-east1-c"]
}

variable "instance_types" {
  type = "map"
  default = {
    data_node = "n1-highmem-8"
    mgt_node  = "n1-standard-2"
  }
}

variable "boot_image" {
    type = "string"
    default = "agones-demo/mysql-ndb"
}

variable "vpc_name" {
  type = "string"
  default = "default"
}

variable "internal_ips" {
  type = "map"
  default = {
    mgt_node_0 = "10.140.0.30"
    mgt_node_1 = "10.140.0.31"
  }
}

variable "mgt_node_internal_ips" {
  type = "list"
  default = ["10.140.0.30", "10.140.0.31"]
}

variable "data_node_internal_ips" {
  type = "list"
  default = ["10.140.0.20", "10.140.0.21"]
}

variable "data_node_network_tags" {
  type = "list"
  default = ["ndb-data"]
}

variable "mgt_node_network_tags" {
  type = "list"
  default = ["ndb-mgt"]
}

variable "service_account_scopes" {
  type = "list"
  default = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append"
    ]
}

variable "data_node_my_cnf_path" {
  type = "string"
  default = "ndb-data/etc/my.cnf"
}

variable "mgt_node_config_path" {
  type = "string"
  default = "ndb-mgt/var/lib/mysql-cluster/config.ini"
}

variable "api_node_mysqld_cnf_path" {
  type = "string"
  default = "ndb-api/etc/mysql/mysql.conf.d/mysqld.cnf"
}

variable "api_node_mysql_cnf_path" {
  type = "string"
  default = "ndb-api/etc/mysql/mysql.cnf"
}

variable "api_node_mysql_service_path" {
  type = "string"
  default = "ndb-api/lib/systemd/system/mysql.service"
}

variable "mgt_node_startup_script_path" {
  type    = "string"
  default = "mgt-node-startup-script.sh"
}

variable "data_node_startup_script_path" {
  type = "string"
  default = "data-node-startup-script.sh"
}
