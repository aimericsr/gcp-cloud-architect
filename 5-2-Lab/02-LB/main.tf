provider "google" {
  credentials = file(var.credentials_file)

  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  credentials = file(var.credentials_file)

  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# VM
data "google_compute_default_service_account" "default" {
}

resource "google_compute_instance" "backend" {
  name         = "backend"
  machine_type = "n1-standard-1"
  zone         = var.zone
  tags         = ["backend"]
  #desired_status = "TERMINATED"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }

  metadata = {
    startup-script-url = "https://storage.googleapis.com/fancy-store-$DEVSHELL_PROJECT_ID/startup-script.sh"
  }
}

resource "google_compute_instance" "frontend" {
  name         = "frontend"
  machine_type = "n1-standard-1"
  zone         = var.zone
  tags         = ["frontend"]
  #desired_status = "TERMINATED"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }

  metadata = {
    startup-script-url = "https://storage.googleapis.com/fancy-store-$DEVSHELL_PROJECT_ID/startup-script.sh"
  }
}

resource "google_compute_firewall" "fw-fe" {
  name      = "fw-fe"
  network   = "default"
  direction = "INGRESS"

  target_tags = ["frontend"]

  priority = "1000"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
}

resource "google_compute_firewall" "fw-be" {
  name      = "fw-be"
  network   = "default"
  direction = "INGRESS"

  target_tags = ["backend"]

  priority = "1000"

  allow {
    protocol = "tcp"
    ports    = ["8081", "8082"]
  }
}

# # Instance Template
resource "google_compute_instance_template" "fancy-be" {
  name         = "fancy-be"
  machine_type = "n1-standard-1"
  tags         = ["backend"]
  #desired_status = "TERMINATED"
  disk {
    source_image = "debian-cloud/debian-11"
    boot         = true
  }
  network_interface {
    network = "default"
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }

  metadata = {
    startup-script-url = "https://storage.googleapis.com/fancy-store-$DEVSHELL_PROJECT_ID/startup-script.sh"
  }
}

resource "google_compute_instance_template" "fancy-fe" {
  name         = "fancy-fe"
  machine_type = "n1-standard-1"
  tags         = ["frontend"]
  #desired_status = "TERMINATED"
  disk {
    source_image = "debian-cloud/debian-11"
    boot         = true
  }
  network_interface {
    network = "default"
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }

  metadata = {
    startup-script-url = "https://storage.googleapis.com/fancy-store-$DEVSHELL_PROJECT_ID/startup-script.sh"
  }
}

# # # Health check for managed instance groups
resource "google_compute_health_check" "fancy-be-hc" {
  name                = "fancy-be-hc"
  check_interval_sec  = 30
  healthy_threshold   = 1
  timeout_sec         = 10
  unhealthy_threshold = 3

  http_health_check {
    port         = "8081"
    request_path = "/api/orders"
  }
}

# # Create managed instance group
resource "google_compute_instance_group_manager" "fancy-be-mig" {
  name               = "fancy-be-mig"
  base_instance_name = "fancy-be"
  zone               = var.zone
  version {
    instance_template = google_compute_instance_template.fancy-be.self_link
  }
  target_size = 2

  named_port {
    name = "orders"
    port = 8081
  }
  named_port {
    name = "products"
    port = 8082
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.fancy-be-hc.self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_autoscaler" "fancy-be-mig-scale" {
  name = "fancy-be-mig-scale"

  target = google_compute_instance_group_manager.fancy-be-mig.self_link
  autoscaling_policy {
    min_replicas = 1
    max_replicas = 2
    load_balancing_utilization {
      target = 0.6
    }
    cooldown_period = 60
  }
}


# # # Health check for managed instance groups
resource "google_compute_health_check" "fancy-fe-hc" {
  name                = "fancy-fe-hc"
  check_interval_sec  = 30
  healthy_threshold   = 1
  timeout_sec         = 10
  unhealthy_threshold = 3

  http_health_check {
    port         = "8080"
    request_path = "/"
  }
}

# # Create managed instance group
resource "google_compute_instance_group_manager" "fancy-fe-mig" {
  name               = "fancy-fe-mig"
  base_instance_name = "fancy-fe"
  zone               = var.zone
  version {
    instance_template = google_compute_instance_template.fancy-fe.self_link
  }
  target_size = 2

  named_port {
    name = "frontend"
    port = 8080
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.fancy-fe-hc.self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_autoscaler" "fancy-fe-mig-scale" {
  name = "fancy-fe-mig-scale"

  target = google_compute_instance_group_manager.fancy-fe-mig.self_link
  autoscaling_policy {
    min_replicas = 1
    max_replicas = 2
    load_balancing_utilization {
      target = 0.6
    }
    cooldown_period = 60
  }
}

# Allow Health Check
resource "google_compute_firewall" "allow-health-check" {
  name      = "allow-health-check"
  network   = "default"
  direction = "INGRESS"

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  #target_tags   = ["allow-health-checks"]

  priority = "1000"

  allow {
    protocol = "tcp"
    ports    = ["8080", "8081"]
  }
}

# # # HTTP Load Balancer

# # # Backend

resource "google_compute_health_check" "fancy-fe-frontend-hc" {
  name = "fancy-fe-frontend-hc"
  http_health_check {
    port         = "8080"
    request_path = "/"
  }
}

resource "google_compute_health_check" "fancy-be-orders-hc" {
  name = "fancy-be-orders-hc"
  http_health_check {
    port         = "8081"
    request_path = "/api/orders"
  }
}

resource "google_compute_health_check" "fancy-be-products-hc" {
  name = "fancy-be-products-hc"
  http_health_check {
    port         = "8082"
    request_path = "/api/products"
  }
}

# # Create backend service
resource "google_compute_backend_service" "fancy-fe-frontend" {
  name                  = "fancy-fe-frontend"
  health_checks         = [google_compute_health_check.fancy-fe-frontend-hc.self_link]
  load_balancing_scheme = "EXTERNAL"
  port_name             = "frontend"
  log_config {
    enable      = true
    sample_rate = 1
  }
  backend {
    # balancing_mode        = "RATE"
    # capacity_scaler       = 1
    # max_rate_per_instance = 50
    group = google_compute_instance_group_manager.fancy-fe-mig.self_link
  }
}

resource "google_compute_backend_service" "fancy-be-orders" {
  name                  = "fancy-be-orders"
  health_checks         = [google_compute_health_check.fancy-be-orders-hc.self_link]
  load_balancing_scheme = "EXTERNAL"
  port_name             = "orders"
  log_config {
    enable      = true
    sample_rate = 1
  }
  backend {
    # balancing_mode  = "UTILIZATION"
    # capacity_scaler = 1
    # max_utilization = 0.6
    group = google_compute_instance_group_manager.fancy-be-mig.self_link
  }
}

resource "google_compute_backend_service" "fancy-be-products" {
  name                  = "fancy-be-products"
  health_checks         = [google_compute_health_check.fancy-be-products-hc.self_link]
  load_balancing_scheme = "EXTERNAL"
  port_name             = "products"
  log_config {
    enable      = true
    sample_rate = 1
  }
  backend {
    # balancing_mode        = "RATE"
    # capacity_scaler       = 1
    # max_rate_per_instance = 50
    group = google_compute_instance_group_manager.fancy-be-mig.self_link
  }
}




# # # Frontend

# Create global static external IP address

# resource "google_compute_address" "my-ephemeral-address" {
#   name   = "my-ephemeral-address"
#   #region = "us-central1"
#   address_type = "EXTERNAL"
#   #purpose = "VPC_PEERING"
# }


resource "google_compute_global_address" "lb-ipv4" {
  provider     = google-beta
  name         = "lb-ipv4-1"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

resource "google_compute_global_address" "lb-ipv6" {
  provider     = google-beta
  name         = "lb-ipv6-1"
  address_type = "EXTERNAL"
  ip_version   = "IPV6"
}

# URL map (name of the load balancer)
resource "google_compute_url_map" "fancy-map" {
  name            = "fancy-map"
  default_service = google_compute_backend_service.fancy-fe-frontend.self_link

  path_matcher {
    name            = "mysite"
    default_service = google_compute_backend_service.fancy-fe-frontend.self_link

    path_rule {
      paths   = ["/api/orders"]
      service = google_compute_backend_service.fancy-be-orders.self_link
    }
    path_rule {
      paths   = ["/api/products"]
      service = google_compute_backend_service.fancy-be-products.self_link
    }
  }
}

# # Proxy HTTP
resource "google_compute_target_http_proxy" "fancy-proxy" {
  name    = "fancy-proxy"
  url_map = google_compute_url_map.fancy-map.self_link
}

# # Forwarding rule (frontend)
resource "google_compute_global_forwarding_rule" "fancy-http-rule" {
  name       = "fancy-http-rule"
  target     = google_compute_target_http_proxy.fancy-proxy.self_link
  port_range = "80"
  #ip_address = google_compute_global_address.lb-ipv4.address
}



