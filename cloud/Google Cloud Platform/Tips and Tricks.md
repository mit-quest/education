# [Google Cloud Platform](https://cloud.google.com/storage/) - Tips and Tricks

- [Google Cloud Platform - Tips and Tricks](#google-cloud-platform---tips-and-tricks)
  - [Google Cloud SDK - Tips and Tricks](#google-cloud-sdk---tips-and-tricks)
    - [Known Gotchas](#known-gotchas)
  - [GCP Compute Engine (VMs)](#gcp-compute-engine-vms)
    - [Tips and Tricks](#tips-and-tricks)
  - [GCS Fuse](#gcs-fuse)
    - [Known Gotchas](#known-gotchas-1)
  - [GCS Drive to Bucket via CoLab](#gcs-drive-to-bucket-via-colab)
    - [Tricks](#tricks)

## [Google Cloud SDK](https://cloud.google.com/sdk/) - Tips and Tricks

### Known Gotchas

*   [gsutil cp](https://cloud.google.com/storage/docs/gsutil/commands/cp)
    *   **Use -m to ensure multithreading**
        *   gsutil **-m** ...
    *   Use -r for directories
        *   gsutil -m cp **-r** src dest

## [GCP Compute Engine (VMs)](https://cloud.google.com/compute/)

### Tips and Tricks

* It is sometimes useful to spin up common configs, for instance:
  * [Pre-confirgured Tensor VM](https://cloud.google.com/ai-platform/deep-learning-vm/docs/tensorflow_start_instance)


## [GCS Fuse](https://cloud.google.com/storage/docs/gcs-fuse)

### Known Gotchas

*   [--implicit-dirs](https://github.com/GoogleCloudPlatform/gcsfuse/blob/master/docs/semantics.md)
    *   We ran into this issue where we uploaded data into a bucket using gsutil and then tried to mount it using GCS Fuse and got a weird behaviour where it wouldn’t find the directories, the solution was to use --implicit-dirs when mounting in order to have it discover the pseudo directories that gsutil created.

## GCS Drive to Bucket via CoLab

### Tricks
* [Medium Blog Tutorial](https://medium.com/@philipplies/transferring-data-from-google-drive-to-google-cloud-storage-using-google-colab-96e088a8c041)

