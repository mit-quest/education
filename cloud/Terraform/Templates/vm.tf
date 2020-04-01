provider "google" {
  project = "test-bridge-project"
  //defaults for these variables that can be overwritten later for specific things
  region  = "us-central1"
  zone    = "us-central1-c"
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "default" {
 name         = "kyle-test-vm"
 machine_type = "f1-micro"
 //zone         = "us-east1-b" //you can overwrite the defaults here

 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-9"
   }
 }

// Make sure flask is installed on all new instances for later steps
 metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync; pip install flask"

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
 }
}
