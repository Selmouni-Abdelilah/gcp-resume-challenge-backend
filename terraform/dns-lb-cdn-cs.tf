#First we will create a Cloud Storage bucket to host the Static Website
        resource "google_storage_bucket" "cloudresume-selmouni" {
        provider = google
        name     = "cloudresume-selmouni1937"
        location = "US"
        website {
                main_page_suffix = "index.html"
                not_found_page   = "error.html"
                }
        }
        # Make new objects public
        resource "google_storage_default_object_access_control" "permissions" {
        bucket = google_storage_bucket.cloudresume-selmouni.id
        role   = "READER"
        entity = "allUsers"
        }
#Create an Ip address and attach it to a managed dns zone 
       # Reserve an external IP
        resource "google_compute_global_address" "ip" {
        provider = google
        name     = "lb-ip"
        }
        # Create a managed DNS zone
        resource "google_dns_managed_zone" "cloudresumedns" {
        provider = google
        name     = "cloudresumedns"
        dns_name = "selmouni.website."
        }

        # Add the IP to the DNS
        resource "google_dns_record_set" "ip" {
        provider     = google
        name         = "challenge.selmouni.website."
        type         = "A"
        ttl          = 300
        managed_zone = google_dns_managed_zone.cloudresumedns.name
        rrdatas      = [google_compute_global_address.ip.address]
        }
#Create a load balancer and enable CDN
       # Add the bucket as a CDN backend
        resource "google_compute_backend_bucket" "lb-backend" {
        provider    = google
        name        = "lb-backend"
        bucket_name = google_storage_bucket.cloudresume-selmouni.name
        enable_cdn  = true
        }
        # Create HTTPS certificate
        resource "google_compute_managed_ssl_certificate" "https-cert" {
        provider = google-beta
        name     = "httpscert"
        managed {
            domains = [google_dns_record_set.ip.name]
        }
        }
        # URL MAP
        resource "google_compute_url_map" "url-map" {
        provider        = google
        name            = "url-map"
        default_service = google_compute_backend_bucket.lb-backend.self_link
        }

        #target proxy
        resource "google_compute_target_https_proxy" "target-proxy" {
        provider         = google
        name             = "target-proxy"
        url_map          = google_compute_url_map.url-map.self_link
        ssl_certificates = [google_compute_managed_ssl_certificate.https-cert.self_link]
        }

        #forwarding rule
        resource "google_compute_global_forwarding_rule" "rule" {
        provider              = google
        name                  = "rule"
        load_balancing_scheme = "EXTERNAL"
        ip_address            = google_compute_global_address.ip.address
        ip_protocol           = "TCP"
        port_range            = "443"
        target                = google_compute_target_https_proxy.target-proxy.self_link
        }