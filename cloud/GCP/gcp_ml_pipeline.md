# How to Create a Machine Learning Pipeline through Google Cloud Platform
## By Julia Wagner, March 31st, 2020


This how-to guide will walk through the steps of creating a machine learning pipeline in Google Cloud Platform. It uses [Fashion MNIST](https://www.tensorflow.org/tutorials/keras/classification) as an example for reference when helpful. 

## Contents  
[Starting with GCP](#starting-with-gcp)  
[Creating your Bucket](#creating-your-bucket)  
[Creating your VM Instance](#creating-your-VM-Instance)  
[Installing Goofys](#installing-goofys)  
[Mounting the Bucket](#mounting-the-bucket)  
[Creating the Python Script](#creating-the-python-script)  
[Adding Tensorboard](#adding-tensorboard)  
[Running the Model on the Instance](#running-the-model-on-the-instance) 
[Stopping the Instance and Buckets](#stopping-the-instance-and-buckets)  
[SSHing from Local Terminal to View localhost](#sshing-from-local-terminal-to-view-localhost)   



## Starting with GCP 

The GCP console is at <https://console.cloud.google.com> and will forward you to your default project if this is already set. You will need to sign into your google account in order to use the console. If you don't already have a GCP account linked, you can get a 12 month free trial with $300 in credit [here](https://cloud.google.com/gcp/?utm_source=google&utm_medium=cpc&utm_campaign=na-US-all-en-dr-bkws-all-all-trial-b-dr-1008076&utm_content=text-ad-lpsitelinkPexp1-any-DEV_c-CRE_353294881636-ADGP_Hybrid+%7C+AW+SEM+%7C+BKWS+%7C+US+%7C+en+%7C+BMM+~+UX+Test+~+gcp-KWID_43700044772255389-kwd-20903505266&utm_term=KW_%2Bgcp-ST_%2Bgcp&gclid=Cj0KCQjwsYb0BRCOARIsAHbLPhF0oYTXkMmXk0H980l13ZDyDtZwxZRSwFesl7XpW7fPv5LNLqOy4rwaAsoqEALw_wcB). 

While you can do most if not all of what you'd want to do with GCP through the console, they also have a gcloud SDK with setup [here](https://cloud.google.com/sdk/docs/quickstarts). This tutorial will explain things through the console, but you can also set up your bucket, VM, and other aspects of the pipeline through the command line using gcloud commands. The commands can also be used to interact with the buckets and instances in many ways once set up.

To create the ML pipeline, you'll specifically interact with the **Storage** and **Compute** sections on the left hand navigation menu in the console, but there are many other options and sections on GCP for things like analytics or other types of projects.

## Creating your Bucket
Start by going to **Storage->Browser** in the [GCP console](https://console.cloud.google.com) and clicking “create bucket”. Give it any unique name and choose the data storage location, class, and access control method. Keeping the defaults is generally okay. 

Click on the bucket and create two folders - output and input. Use the upload files option to put whatever files (training and testing images and labels) you’ll need into the input folder. Depending on your machine learning script, you could also download data at runtime like in the Fashion MNIST Tutorial. 

## Creating your VM Instance
Go to **Compute Engine -> VM Instances** in the console. Click create instance and search in the Marketplace for a pre-made VM with the software you need (Deep Learning VM by Google Click to Deploy is good for general machine learning). Feel free to mess around with the naming and defaults if there’s anything you want to change, and then deploy the instance! 

After the instance is deployed, you can use a command line on the instance by clicking the SSH button next to the instance name and opening it in your browser. You could also use gcloud commmands or set up SSH keys to access it from a local terminal. See the end of this guide if you’d like to set up SSH from your local terminal, which includes options such as port forwarding. If you want to use flags you may be familiar with for the ssh command, you'll need to use one of the latter two options rather than the browser shortcut. 

Once on the instance, you can install `pip3` and other packages with

```
sudo apt-get install python3-pip 
pip3 install tensorflow
pip3 install numpy 
pip3 install matplotlib
```

If you use the pre-made solution, this may not be necessary. You can check whether python packages are installed by running 

```
python3
import [package]
```
and seeing whether it throws an error. While pip3 will check if the requirement is already satisfied before installing something, you should be careful not to accidentally install multiple copies of the same library.

## Installing Goofys

For ML pipelines with smaller datasets, such as Fashion MNIST, mounting the bucket isn't strictly necessary. With these, loading and outputting all data using GCP storage is fine. However, many pipelines involve much larger datasets and output needs. Mounting a bucket with cloud storage space to the instance is a way around storage limitations when using larger datasets. Storage is not used up on the instance, but processes on the VM still see the bucket as a part of the file system.

One possible mounting system to use to mount the object storage bucket on our VM instance is [Goofys](https://github.com/kahing/goofys). To install Goofys and mount the bucket manually, follow this guide. Alternatively, you can use the script [here](../scripts/mount_bucket_goofys.sh) which installs Goofys with its dependencies and mounts your bucket at the given argument. See the beginning of the [Mounting the Bucket](#mounting-the-bucket)
section below to gain the access key and secret that you'll need to put in your script. Then you can run it with 

```./mount_bucket_goofys.sh [BUCKET] [MOUNT_DIR]```

from the directory where you'll hold your bucket and the Goofys installation. If you don't want to use the script, continue on here. 

Since the VM uses linux, you can install via the pre-built binaries or build the Go code after getting it from github. To install via binaries, run 

```wget https://github.com/kahing/goofys/releases/latest/download/goofys```

You should run this in the directory that holds the directory in which you'll mount you bucket. Then, run 

```chmod a+rx goofys```

This makes `goofys` executable and readable. 
When in this folder, you can run Goofys commands with `./goofys [command]`. You can run commands from other places by giving the whole path to `goofys`. 

If you want to make the `goofys` commands accessable from _anywhere_ on the instance, move the output to `/usr/bin` and then run the above `chmod` command. This likely isn't necessary unless you plan to mount multiple buckets in different areas. 

You also need to install `fuse` as it is used in Goofys commands. 

```sudo apt-get install fuse```

Now you are all set up to use Goofys! 

### Notes: 

During my first use of Goofys, I got the error 

```main.FATAL Unable to mount file system, see syslog for details. ```

The `syslog` is found in `/var/log/syslog`, and this is how I discovered `fuse` was needed in addition to `goofys`. 

<br/> 

If you ever forget to include the `sudo` command, you can run
`sudo !!`
which runs the previous command with `sudo`. 

## Mounting the Bucket

The steps to mount the bucket using Goofys come from the documentation [here](https://github.com/kahing/goofys/wiki/mount-google-cloud-storage). 

On the left dropdown within the Storage section, select settings and then interoperability. Select your default project (whatever it suggests is probably fine), and then click “Create a key”. This will provide you with an **access key** and a **secret**. 

You’ll next need to put both the access key and secret in a “google” profile in the file `~/.aws/credentials`. If the `~/.aws` directory has not been created in the instance (i.e., aws has not been used), you should run

```
mkdir ~/.aws
touch ~/.aws/credentials
```

The first command creates the directory `~/.aws`. This resides in the Users directory (`~`) and is a hidden folder, due to the prefix dot. The second command creates a file called `credentials` in the `aws` folder if it does not exist. Within this file, using your editor of choice (I personally use vim), you should add the profile as is formatted for aws tools. Since Goofys is originally coded to work with S3 buckets on aws, we add a “google” profile in the aws credentials file, seen below. 

```
[google]
aws_access_key_id=ACCESS_KEY
aws_secret_access_key=SECRET
```

After the profile has been created, we are ready to mount the bucket using Goofys. Create the folder you want to mount your bucket in (the folder will be virtually equivalent to your bucket). This folder should be in the same directory that `goofys` is in, unless you moved `goofys` to `/usr/bin` earlier. Within that folder, run 

```
./goofys --profile google --endpoint https://storage.googleapis.com BUCKET_NAME BUCKET_DIR_NAME
```

It uses the `goofys` command, selecting our specific profile “google”. The endpoint must be included for interoperability reasons as can be seen on the settings page where you earlier retrieved your keys. `BUCKET_NAME` is the unique name you chose for your bucket earlier. `BUCKET_DIR_NAME` is the directory which you are mounting the bucket to. 

Hooray! You should be able to see your `output` and `input` folders and the data that’s in them if you `cd` into the mounted bucket. Within your bucket folder but outside of the `output` or `input` folders, try 

```touch tmp.txt```

This will show up on the google console browser when you look at the objects in your bucket. If you remove it (`rm tmp.txt`), it will disappear in both places. 

To unmount on linux, use 
```umount path/to/bucket```

To unmount on Mac, use 

```umount path/to/bucket```

or if that doesn’t work then 

```diskutil unmount path/to/bucket```

### Notes

Mounting the bucket in a folder with other contents will make those contents unusable until the bucket is unmounted. 

## Creating the Python Script

For a thorough explanation and tutorial on creating a python script for machine learning, see the Fashion MNIST Tutorial [here](https://www.tensorflow.org/tutorials/keras/classification). 

Here are a few changes of note when working on a VM rather than locally. 

Since the bucket is mounted on the VM, you can access data (for reading and writing) through the filepath as you would on a local machine in your machine learning script. The Fashion MNIST Tutorial downloads its data at the beginning of its process.
 
Run your model as you would usually, with the option to write data to output files if the model will be running in the background. 

If you want to apply the predictions on a large dataset (larger than can be held in variables at once), you can iterate through data in the bucket and write the predictions to a file one by one. 

## Adding Tensorboard 

Tensorboard is a great tool for tracking analysis while your model is running. Documentation to add it to your script is [here](https://www.tensorflow.org/tensorboard/get_started). 

Notably, add a callbacks variable and feed it into your fit command. 

```
tensorboard_callback = tf.keras.callbacks.TensorBoard(log_dir=log_dir, histogram_freq=1)
model.fit(train_images, train_labels, epochs=10,callbacks=[tensorboard_callback])
```

This stores logs in a log_dir directory, which can be inside of your bucket. You can access the logs at <localhost:6006> after running 

```tensorboard --logdir LOG_DIR```

To access the localhost of the VM, the easiest way is by adding flags and SSHing from your local terminal. See the [section on SSHing](#sshing-from-local-terminal-to-view-localhost) below for specific steps. 

## Running the Model on the Instance

Now that your bucket, instance, and script are ready, you can run the script on the VM. 

If your file is not on the instance, there are a few ways to upload it. The easiest and most similar to previous steps is by going to the GCP console, navigating to the bucket you created through **Storage**, and uploading your file to the bucket in the same way that you uploaded data to folders earlier. Additionally, you can use `scp` (see general steps [here](https://linuxize.com/post/how-to-use-scp-command-to-securely-transfer-files/), requires SSH key setup below) or place it on your local file system into the bucket (you can download Goofys on your machine the same way as above). 

You can now run the script from within the VM browser or add in your own SSH keys to run it from your own ssh terminal. Assuming your script is in python and you have accesss to the VM command line through the browser or ssh, navigate to the bucket. To check and see whether your script is set up correctly, set loops and equivalent structures to a low iteration count just to make sure it can read and output files correctly. All file paths must be accurate from the directory in which you ran the script, if relative. Thus, it's easier to use absolute file paths. You can always run `pwd` to print out the path of the current directory, specifically the bucket, in order to figure out the absolute path. When this version is ready, run

```python3 my_model.py```

Confirm that there are no import errors, errors with regards to reading or writing to files in the bucket, or other issues with the skeleton of the script. If using Tensorboard, now is also a good time to check an initial log on localhost to make sure things are being stored correctly. 

When everything looks good, you should be able to let the model run without constantly watching. It’s important for the script to continue running on the instance even without a user logged in, and for this you can use `screen` (type command `screen` and then run the script process in the VM terminal). 

```screen```

```python3 my_model.py```

Screen will run the model in the background in a separate terminal on the instance. If you also want the process to ignore interrupt signals, you could use `nohup`. 

## Stopping the Instance and Buckets 

When you aren’t using the VM instance, you should stop it from the compute engine section on the console. This enables you to keep your setup without incurring fees. Leaving things in the bucket is relatively cheap, so it’s not a problem to leave your data in these. 

## SSHing from Local Terminal to View localhost
First, make sure you have SSH keys set up on your local environment (a general guide is [here](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2)). 

You can then find the external IP address for your instance on the instances page in the fourth column and copy it to your clipboard. 

Click on the instance and click edit in order to add your public SSH key. This key is generally stored on your local computer at `~/.ssh/id_rsa.pub`. When you add it as an SSH key to the instance, change the username at the end to the username you use on the console so you can access the same files as if you used the browser SSH method. More details can be found [here](https://cloud.google.com/compute/docs/instances/connecting-advanced#thirdpartytools).

Now, you can ssh from local terminal using 

```ssh username@IP```

It may ask for your password if you have set one up for your SSH keys. 

To also forward data sent to a port on the VM (for Tensorboard this is port 6006), you can run it with the -L flag as so 

```ssh -L 6006:localhost:6006 username@IP```

Now, when you run the Tensorboard command mentioned earlier localhost:6006 will have your analysis. It forwards anything on data sent to port 6006 on the VM (client machine) to port 6006 on your local machine.

With all of this, you should be good to go with creating your ML pipeline on GCP! 

[Back to Top](#How-to-Create-a-Machine-Learning-Pipeline-through-Google-Cloud-Platform)

<br>  

[Back to GCP](README.md)