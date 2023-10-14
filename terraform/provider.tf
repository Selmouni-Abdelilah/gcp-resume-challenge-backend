provider "google" {
  credentials  = var.svc_key
  project      = var.project
  region       = var.region
}
provider "google-beta" {
  credentials  = var.svc_key
  project      = var.project
  region       = var.region
}