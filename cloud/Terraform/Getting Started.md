# Terraform + GCP  - Usage Guide

- [Terraform + GCP  - Usage Guide](#terraform--gcp---usage-guide)
  - [Setup Instructions](#setup-instructions)
  - [GCP Cloud Functions](#gcp-cloud-functions)
  - [Connecting to an Instance / Setting up SSH](#connecting-to-an-instance--setting-up-ssh)
    - [Set up SSH for provisioning](#set-up-ssh-for-provisioning)
  - [Mounting a bucket](#mounting-a-bucket)

## Setup Instructions

The [official setup guide](https://www.terraform.io/docs/providers/google/guides/getting_started.html) is thorough and has many useful links, but the actual config file threw unsolvable errors. This [older community guide](https://cloud.google.com/community/tutorials/getting-started-on-gcp-with-terraform) worked much better with the config file and telling you to run terraform init. Below is our summary of the steps. 

*   Setting up terraform
    *   Download and Install Terraform CLI - [full instructions](https://learn.hashicorp.com/terraform/getting-started/install.html)
        *   [https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html) 
        *   Move file somewhere and put it on PATH
        *   Run “terraform” to verify
*   Connecting terraform to GCP
    *   [Get GCP Project ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects)
    *   Ran through their setup page and got confused by the diff, but think we created the correct file. The region is not something you need to look up as the project ID is, it is a config declaration
    *   Download [JSON key file from GCC](https://console.cloud.google.com/apis/credentials/serviceaccountkey?project=test-bridge-project&folder&organizationId=795788308688)
    *   Save location of JSON key file in local environment variable
        *   GOOGLE_CLOUD_KEYFILE_JSON
*   Using terraform for Bucket
    *   Download [bucket.tf](https://drive.google.com/a/mit.edu/file/d/1uKu4vPl5I4HHxjdT8hGpQ-qgomVdZdR8/view?usp=sharing) and [vm.tf](https://drive.google.com/a/mit.edu/file/d/1GngorrHUs0CAK3ga38f8WmZwydRsGFug/view?usp=sharing)
    *   Save the files locally in a directory that you can get to using your terminal
    *   `terraform init` in directory containing main.tf
    *   `terraform apply` in directory containing main.tf
    *   `terraform destroy` in directory containing main.tf


## GCP Cloud Functions

*   [Terraform Docs](https://www.terraform.io/docs/providers/google/r/cloudfunctions_function.html)

## Connecting to an Instance / Setting up SSH

*   Run `ssh-keygen` to create a public/private rsa key pair
    *   [Create terraform variable](https://www.terraform.io/docs/configuration/variables.html#variable-definitions-tfvars-files) to the path of the public key (.pub file)
    *   Create terraform variable to the path of the private key (the other file)
*   You will also need a [service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts) key. You will need proper permissions in order to create a service account. Download the json file and put it somewhere safe! 
    *   Create terraform variable to the path of the service account key <br> 
        ``` 
            provider "google" {
                ....
                credentials = "${var.gcp_key_file_location}"
            }
        ``` 
    *   Make sure to add the service account information (credentials) in this code block
*   Next, inside of where you are creating a VM instance, add the metadata to set up sshKeys. Note: whatever username you put here, will be what you use to ssh into the VM instance. <br>
    ```
        metadata = {
            sshKeys = "${var.username}:${file(var.ssh_public_key_filepath)}"
        }
    ```
*   Now create a VM instance! If you don’t know the IP address of your instance, you can output it by adding this command. <br>
    ```
        output "external_ip" {
        value =  google_compute_instance.default.network_interface.0.access_config.0.nat_ip
        }
    ```
*   The output should look like this and should give you an IP address <br>
    ```
        Outputs:
        external_ip = 35.231.142.146
    ```

*   Now you should be able to ssh into the VM instance using your command line! You can also ssh into the instance on console.cloud.google.com but this is cooler
*   **Using the username that you used when establishing the sshKeys metadata,** you should
    *   `ssh username@35.231.142.146`
    *   If your ssh private key is in a weird place, put the path while sshing
        *   `ssh -i path/to/privatekey username@35.231.142.146`


### Set up SSH for provisioning

*   You might be wondering why I made you save your private key to a variable! For [provisioning](https://www.terraform.io/docs/provisioners/index.html)! Provisioning allows us to run setup files locally or on the VM. Make sure this code is inside of the code block of the VM instance <br>
    ```
        provisioner "remote-exec" {
            inline = [
            "echo 'Running resource creation script... (this may take 10+ minutes)'"
            ]
            connection {
            user        = "${var.username}"
            type        = "ssh"
            private_key = "${file(var.private_ssh_key_location)}"
            host        = "${self.network_interface[0].access_config[0].nat_ip}"
            }
        }
    ```
*   Again, your username should be the same as what you used to establish the sshKeys metadata
*   Make sure your private_key directs to the path of the private key you generated earlier
*   Host is the IP address of the VM instance 
*   This should run whatever commands specified in the “inline” array
*   There are other built- in provisioners like “local-exec” and “file” and more
*   Useful [link ](https://www.terraform.io/docs/provisioners/remote-exec.html#script-arguments)you’re trying to do something fancy with shell files (.sh files)


## Mounting a bucket

*   After opening up the VM, [install gcsfuse](https://github.com/GoogleCloudPlatform/gcsfuse/blob/master/docs/installing.md#ubuntu-and-debian-latest-releases)
*   Make sure you have proper permissions in console.cloud.google.com for the bucket you are trying to access! This step is a bit finicky and will prevent you from seeing the contents of the bucket
*   Create a directory to hold the bucket content and run 
    *   `gcsfuse my-bucket /path/to/mount`
    *   If you added buckets via gsutil, some directories might not show up. Try this instead: 
        *   `gcsfuse --implicit-dirs my-bucket /path/to/mount`
