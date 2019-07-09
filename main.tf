provider "google" {
 credentials = "${file("credentials.json")}"
 project     = "${var.project_id}"
}

/*** create data node my.cnf file ***/
data "template_file" "data_node_my_cnf" {
  template = "${file(format("templates/%s.tpl", "${var.data_node_my_cnf_path}"))}"
  vars = {
    ndb_connectstring = join(",", "${var.mgt_node_internal_ips}")
  }
}

resource "local_file" "data_node_my_cnf" {
    content  = "${data.template_file.data_node_my_cnf.rendered}"
    filename = format("conf/%s", "${var.data_node_my_cnf_path}")
}

resource "google_storage_bucket_object" "data_node_my_cnf" {
  name   = "${var.data_node_my_cnf_path}"
  source = format("conf/%s", "${var.data_node_my_cnf_path}")
  bucket = "${var.bucket_name}"

  depends_on = [local_file.data_node_my_cnf]
}

/*** create mgt node cluster config.ini file ***/
data "template_file" "mgt_node_config" {
  template = "${file(format("templates/%s.tpl", "${var.mgt_node_config_path}"))}"
  vars = {
    mgt_node_0_ip  = "${var.mgt_node_internal_ips[0]}"
    mgt_node_1_ip  = "${var.mgt_node_internal_ips[1]}"
    data_node_0_ip = "${var.data_node_internal_ips[0]}"
    data_node_1_ip = "${var.data_node_internal_ips[1]}"
    api_node_0_ip  = "${var.data_node_internal_ips[0]}"
    api_node_1_ip  = "${var.data_node_internal_ips[1]}"
  }
}

resource "local_file" "mgt_node_config" {
    content  = "${data.template_file.mgt_node_config.rendered}"
    filename = format("conf/%s", "${var.mgt_node_config_path}")
}

resource "google_storage_bucket_object" "mgt_node_config" {
  name   = "${var.mgt_node_config_path}"
  source = format("conf/%s", "${var.mgt_node_config_path}")
  bucket = "${var.bucket_name}"

  depends_on = [local_file.mgt_node_config]
}

/*** create api node mysqld.cnf ***/
data "template_file" "api_node_mysqld_cnf" {
  template = "${file(format("templates/%s.tpl", "${var.api_node_mysqld_cnf_path}"))}"
  vars = {
    ndb_connectstring = join(",", "${var.mgt_node_internal_ips}")
  }
}

resource "local_file" "api_node_mysqld_cnf" {
  content  = "${data.template_file.api_node_mysqld_cnf.rendered}"
  filename = format("conf/%s", "${var.api_node_mysqld_cnf_path}")
}

resource "google_storage_bucket_object" "api_node_mysqld_cnf" {
  name   = "${var.api_node_mysqld_cnf_path}"
  source = format("conf/%s", "${var.api_node_mysqld_cnf_path}")
  bucket = "${var.bucket_name}"

  depends_on = [local_file.api_node_mysqld_cnf]
}

/*** create api node mysql.cnf file ***/
data "template_file" "api_node_mysql_cnf" {
  template = "${file(format("templates/%s.tpl", "${var.api_node_mysql_cnf_path}"))}"
  vars = {
    ndb_connectstring = join(",", "${var.mgt_node_internal_ips}")
  }
}

resource "local_file" "api_node_mysql_cnf" {
  content  = "${data.template_file.api_node_mysql_cnf.rendered}"
  filename = format("conf/%s", "${var.api_node_mysql_cnf_path}")
}

resource "google_storage_bucket_object" "api_node_mysql_cnf" {
  name   = "${var.api_node_mysql_cnf_path}"
  source = format("conf/%s", "${var.api_node_mysql_cnf_path}")
  bucket = "${var.bucket_name}"

  depends_on = [local_file.api_node_mysql_cnf]
}

/*** create api node mysql.service file ***/
data "template_file" "api_node_mysql_service" {
  template = "${file(format("templates/%s.tpl", "${var.api_node_mysql_service_path}"))}"
}

resource "local_file" "api_node_mysql_service" {
  content  = "${data.template_file.api_node_mysql_service.rendered}"
  filename = format("conf/%s", "${var.api_node_mysql_service_path}")
}

resource "google_storage_bucket_object" "api_node_mysql_service" {
  name   = "${var.api_node_mysql_service_path}"
  source = format("conf/%s", "${var.api_node_mysql_service_path}")
  bucket = "${var.bucket_name}"

  depends_on = [local_file.api_node_mysql_service]
}

/*** create mgt startup script ***/
data "template_file" "mgt_node_startup_script" {
  template = "${file(format("templates/%s.tpl", "${var.mgt_node_startup_script_path}"))}"
  vars = {
    ndb-conf-bucket = "${var.bucket_name}"
    mgt-cluster-conf-path = "${google_storage_bucket_object.mgt_node_config.name}"
  }
}

resource "local_file" "mgt_node_startup_script" {
  content  = "${data.template_file.mgt_node_startup_script.rendered}"
  filename = format("conf/%s", "${var.mgt_node_startup_script_path}")

  depends_on = [data.template_file.mgt_node_startup_script]
}

resource "google_storage_bucket_object" "mgt_node_startup_script" {
  name   = "${var.mgt_node_startup_script_path}"
  source = format("conf/%s", "${var.mgt_node_startup_script_path}")
  bucket = "${var.bucket_name}"

  depends_on = [local_file.mgt_node_startup_script]
}

/*** create mgt nodes ***/
resource "google_compute_instance" "ndb_mgt" {

  count = "${length(var.mgt_node_internal_ips)}"

  name         = "terraform-ndb-mgt-${count.index}"
  machine_type = "${var.instance_types.mgt_node}"
  zone         = "${element(var.zones, count.index)}"

  tags = "${var.mgt_node_network_tags}"

  boot_disk {
    initialize_params {
      image = "${var.boot_image}"
    }
  }

  network_interface {
    network    = "${var.vpc_name}"
    network_ip = "${element(var.mgt_node_internal_ips, count.index)}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    startup-script-url = "gs://${var.bucket_name}/${var.mgt_node_startup_script_path}"
  }

  service_account {
    scopes = "${var.service_account_scopes}"
  }

  depends_on = [google_storage_bucket_object.mgt_node_startup_script]
}



/*** create data node startup script ***/
data "template_file" "data_node_startup_script" {
  template = "${file(format("templates/%s.tpl", "${var.data_node_startup_script_path}"))}"
  vars = {
    ndb-conf-bucket          = "${var.bucket_name}"
    data-node-my-cnf-path    = "${google_storage_bucket_object.data_node_my_cnf.name}"
    api-node-mysql-cnf-path  = "${google_storage_bucket_object.api_node_mysql_cnf.name}"
    api-node-mysqld-cnf-path = "${google_storage_bucket_object.api_node_mysqld_cnf.name}"
    api-node-mysql-service   = "${google_storage_bucket_object.api_node_mysql_service.name}"
  }
}

resource "local_file" "data_node_startup_script" {
  content  = "${data.template_file.data_node_startup_script.rendered}"
  filename = format("conf/%s", "${var.data_node_startup_script_path}")

  depends_on = [data.template_file.data_node_startup_script]
}

resource "google_storage_bucket_object" "data_node_startup_script" {
  name   = "${var.data_node_startup_script_path}"
  source = format("conf/%s", "${var.data_node_startup_script_path}")
  bucket = "${var.bucket_name}"

  depends_on = [local_file.data_node_startup_script]
}

/*** create mgt nodes ***/
resource "google_compute_instance" "ndb_data" {

  count = "${length(var.data_node_internal_ips)}"

  name         = "terraform-ndb-data-${count.index}"
  machine_type = "${var.instance_types.data_node}"
  zone         = "${element(var.zones, count.index)}"

  tags = "${var.data_node_network_tags}"

  boot_disk {
    initialize_params {
      image = "${var.boot_image}"
      type = "pd-standard"
      size = "200"

    }
  }

  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network    = "${var.vpc_name}"
    network_ip = "${element(var.data_node_internal_ips, count.index)}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    startup-script-url = "gs://${var.bucket_name}/${var.data_node_startup_script_path}"
  }

  service_account {
    scopes = "${var.service_account_scopes}"
  }

  depends_on = [google_storage_bucket_object.data_node_startup_script]
}
