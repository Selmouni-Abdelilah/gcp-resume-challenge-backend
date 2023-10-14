#Cloud Storage bucket to host Cloud function Code
    # Bucket to host the cloud function
    resource "google_storage_bucket" "cloudresume_function" {
    name     = "cloudresume-function-bucket"
    location = var.region
    storage_class = "REGIONAL"
    }
#Cloud function and its public execution
    # Deploy the cloud function
    resource "google_cloudfunctions_function" "current_number_visitors" {
    name        = "cloudresume-visitors"
    runtime     = "python37"
    entry_point = "current_number_visitors"
    source_archive_bucket = google_storage_bucket.cloudresume_function.name
    source_archive_object = var.zip_file
    max_instances      = 10
    available_memory_mb = 128
    timeout            = 3
    trigger_http = true
    }

    # Allow everyone to execute the function
    resource "google_cloudfunctions_function_iam_member" "public_access_function" {
    project = var.project
    region  = var.region
    cloud_function    = google_cloudfunctions_function.current_number_visitors.name
    role    = "roles/cloudfunctions.invoker"
    member  = "allUsers"
    }
            