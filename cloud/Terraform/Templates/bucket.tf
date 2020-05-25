provider "google" {
  project = "test-bridge-project"
  //defaults for these variables that can be overwritten later for specific things
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_storage_bucket" "image-store" {
  name     = "kyle-test-image-store-bucket"
  location = "us-east1"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}
