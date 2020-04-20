# How to Create a Machine Learning Pipeline through Satori
## By Julia Wagner, April 6th, 2020


This how-to guide will walk through the steps of creating a machine learning pipeline on [Satori](https://satori-portal.mit.edu/pun/sys/dashboard), an MIT only cloud platform. It uses [Fashion MNIST](https://www.tensorflow.org/tutorials/keras/classification) as an example for reference when helpful. 

## Contents  
[Starting with Satori](#starting-with-satori)  
[Creating your Directories](#creating-your-directories)  
[Setting Up Your Environment](#setting-up-your-environment)  
[Runnning an Interactive Job](#running-an-interactive-job)  
[Creating the Python Script](#creating-the-python-script)  
[Adding Tensorboard](#adding-tensorboard)  
[Running the Model Using a Batch Script](#running-the-model-using-a-batch-script)  
[SSHing from Local Terminal to view localhost](#sshing-from-local-terminal-to-view-localhost)  



## Starting with Satori

The Satori portal login is at <https://satori-portal.mit.edu>. It requires MIT Kerberos credntials to sign in, so it's currently not open to the larger community. It is free with kerberos credentials. The overall wiki with all things Satori can be found [here](https://mit-satori.github.io/), and you should check out the code of conduct [here](https://mit-satori.github.io/ause-coc.html?highlight=resource).

Satori, in comparison to other cloud providers, is a compute cluster meant for very computation intensive projects (see Satori basics [here](https://mit-satori.github.io/satori-basics.html#satori-basics)). It is for GPU heavy computation, and each node has four GPUs. Thus, projects with little CPU usage should not go down this route. It is also important to note that resources on Satori are shared with all other users. *This means that projects may have to sit in a queue before use and can be cut off due to time constraints*. In the future, it is moving toward the [Slurm Workload Manager](https://slurm.schedmd.com/overview.html) to allocate resource access.

Additionally, it is different from providers like GCP in that there is not a notion of "creating an instance" or "creating a bucket." This also means that there is no necessary deleting of buckets or stopping of instances. The data you put in Satori folders is stored on a filesystem along with all other users' data, so you don't need to mount anything. Set your permissions accordingly! When you initially start up a shell in Satori, you are connecting to a "login node". You *cannot* run computation here, as the memory allocation bounds are extremely limited. To do so, you'll need to submit an interactive job or batch script to gain a finite amount of time on a "compute node" where you can better utilize resources. This time is assigned after a potential wait in a queue. There is more detail on changing node types below in [Runnning an Interactive Job](#running-an-interactive-job).

After you log in with your kerberos at the [portal](https://satori-portal.mit.edu) and "Authenticate with Globus" (select Massachusetts Institute of Technology), you're ready to get started. You can do most of what you'd want to do on Satori through this portal (access a terminal, monitor jobs, browse/transfer files), but you can also SSH Login into the Satori cluster as detailed [here](https://mit-satori.github.io/satori-ssh.html#ssh-login). A general guide for setting up SSH keys, in case your's are not yet set up, is [here](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2). This tutorial will mostly explain things through the portal where possible.

To create the ML pipeline, you'll specifically interact with the **Files**, **Jobs**, and **Clusters** sections on the drop down navigation menu in the portal. There are fewer snazzy options on Satori than on cloud platforms like GCP, as it is mainly meant for high GPU usage. 

## Creating your Directories
Start by going to **Files->Home Directory** in the [Satori Portal](https://satori-portal.mit.edu) and clicking “New Dir”. You can give this folder the name of your project, and then click on the folder to create both an output and input directory within it. You can now use the upload button to add whatever files (training and testing images and labels) you'll need. Depending on your machine learning script, you could also download data at runtime like in the Fashion MNIST Tutorial. 

Note that the permissions for data on Satori are default set at `755`, or `rwx` for user and `r_x` for group and others. To change this so MIT users are not able to look at the contents of your directory, open up a shell by going to **Clusters -> Satori Shell Access**. Run 

```chmod 700 /home/KERBEROS```

in order to give rwx access to the user and no permissions to all others.

## Setting up Your Environment
In other cloud platforms, you may need to create a specific VM instance to work on. On Satori as mentioned, [opening up a terminal](https://mit-satori.github.io/satori-ssh.html?highlight=ssh) at **Clusters -> Satori Shell Access** accesses a terminal that runs on the login node. To reach the login node, you also can use SSH and run 

`ssh <your_username>@satori-login-001.mit.edu`

with port forwarding options described at the end of this guide. If you want to use flags you may be familiar with for the ssh command, you'll need to avoid accessing through the browser.

From here you can run terminal commands that do not involve computation. For computation, you can submit a batch job or start an interactive session in order to transfer to a compute node, explained in later sections.

First, you'll need to make sure you have the modules that contain the necessary software. This is explained in detail [here](https://mit-satori.github.io/satori-getting-started.html#setting-up-your-environment). As of the writing of this guide, the default modules (`wmlce/1.7.0` specifically) cover most of prerequisites needed for many ML projects, this one included. The manual approach is [here](https://mit-satori.github.io/satori-ai-frameworks.html#install-anaconda).

If you'd like to install your dependencies in a virtual environment (details [here](https://mit-satori.github.io/satori-ai-frameworks.html#wmlce-creating-and-activate-conda-environments-recommended)), the default modules give you the software to do so. Run

`conda create --name my_env python=3.7`

`conda activate my_env`

Then, you'll be in your virtual environment. If you receive an error that your shell has not been properly configured, run the command given as 

`conda init bash` (which sometimes works)

or 

`source $/home/softwarre/wmlce/1.7.0/etc/profile.d/conda.sh`

which will access the main initialization file on Satori if you used the module approach. 

Due to the nature of virtual environments which do not access default modules, you should use 

`module load wmlce/1.6.2` 

before or after (module uplaods are persistent to the session) in order to use Tensorflow. We install wmlce/1.6.2 instead of wmlce/1.7.0 because the latter had a CUDA driver version incompatibility as of the writing of this guide when used in virtual environmnents. Module loads do not stay in your virtual environment between console sessions, so if you want to manually install dependencies so they are persistent, consider [this approach](https://mit-satori.github.io/satori-ai-frameworks.html?highlight=ptile#install-anaconda).

After these steps, you can deactivate the environment with 

`conda deactivate my_env` 

and remove it with

`conda remove --name my_env --all` 

which removes all packages from the environment. You can see a list of current environments with 

`conda info --envs`

and can store each with different dependencies. After you activate an environment, the rest of the module commands work as normal. Most packages, if you need others than the default modules, can be installed with 

`conda install package`

## Running an Interactive Job

The [steps above](#setting-up-your-environment) can be completed on either a login node or compute node. To go much further, though, whether it be testing or running a python script, you need to set up for computational work, original documents [here](https://mit-satori.github.io/satori-workload-manager.html#). Overall, since Satori is a shared resource, you must request time and be entered in a queue to receive computation power.

To launch an interactive shell where you have terminal access (similar to a VM), you can request an interactive batch job from within your browser or ssh terminal with 

`bsub -W 3:00 -q normal -gpu "num=4" -R "select[type==any]" -Ip bash`

This asks for an AC922 node with 4 GPUs from the normal queue for 3 hours. Note that these GPUs may not exclusively be used by you, and if you need this you should run

`bsub -W 3:00 -x -q normalx -gpu "num=4:mode=exclusive_process" -Is /bin/bash`

instead. After (usually) a few minutes of wait time, you have shell access to your compute node and can run things as normal. If using a virtual environment, you must run this command outside of the virtual environment in order to be able to deactivate it when on the compute node. Equivalently, do not activate your environment until you're on the compute node.

Again, an interactive job is helpful for when you need to be able to interact with the code over time rather than leaving it as a background script (testing, debugging, etc.). You can check on or delete your running jobs on the portal at **Jobs -> Active Jobs**. 

Now, you can check to make sure your dependencies are working. As a brief tensorflow check, you can run the below in Python 3. 

```
from __future__ import print_function
import tensorflow as tf
# Create a Constant op
# The op is added as a node to the default graph.
#
# The value returned by the constructor represents the output
# of the Constant op.
hello = tf.constant('Hello, TensorFlow!')
# Start tf session
sess = tf.Session()
# Run the op
print(sess.run(hello))
```

This makes sure that tensorflow is installed and can allocate memory (running this on the login node will throw an error). You can include other imports (like `numpy`) as well to make sure they're there or check out [these](https://mit-satori.github.io/satori-ai-frameworks.html#wmlce-testing-ml-dl-frameworks-pytorch-tensorflow-etc-installation) example tests. You should test a small version of your python script using an interactive job in order to debug it before submitting to a batch job, which we'll go over in [Checking the Script](#checking-the-script).

## Creating the Python Script

For a thorough explanation and tutorial on creating a python script for machine learning, see the Fashion MNIST Tutorial [here](https://www.tensorflow.org/tutorials/keras/classification). 

Here are a few changes of note when working through Satori rather than locally. 

You can access data (for reading and writing) through the filepath as you would on a local machine in your machine learning script. The Fashion MNIST Tutorial downloads its data at the beginning of its process.
 
Run your model as you would usually, with the option to write data to output files if the model will be running in the background (like in a batch script). 

If you want to apply the predictions on a large dataset (larger than can be held in variables at once), you can iterate through data and write the predictions to a file one by one. 

## Adding Tensorboard 

Tensorboard is a great tool for tracking analysis while your model is running. Documentation to add it to your script is [here](https://www.tensorflow.org/tensorboard/get_started). 

Notably, add a callbacks variable and feed it into your fit command. 

```
tensorboard_callback = tf.keras.callbacks.TensorBoard(log_dir=log_dir, histogram_freq=1)
model.fit(train_images, train_labels, epochs=10,callbacks=[tensorboard_callback])
```

This stores logs in a log_dir directory, which can be inside of your project directory. You can access the logs at <localhost:6006> after running 

```tensorboard --logdir LOG_DIR```

To access the localhost of the node, the easiest way is by adding flags and SSHing from your local terminal. See the section on SSHing below for specific steps. 

## Checking the Script 

Before going to a batch script, you should start up an [Interactive Job](#running-an-interactive-job) and confirm that there are no errors. 

If your file is not on the instance, there are a few ways to upload it. The easiest and most similar to previous steps is by going to the Satori Dashboard, choosing you folder through **Files -> Home Directory**, and uploading your file in the same way that you uploaded data to folders earlier. Additionally, you can use `scp` (steps [here](https://mit-satori.github.io/satori-getting-started.html?highlight=scp#using-scp-or-rysnc), requires SSH key setup below). 

You can now run the script from within the browser or add SSH keys to run it from your own ssh terminal. Assuming your script is in python and you have accesss to the  command line through the browser or ssh, navigate to the project folder. To check and see whether your script is set up correctly, set loops and equivalent structures to a low iteration count just to make sure it can read and output files correctly. All file paths must be accurate from the directory in which you ran the script, if relative. Thus, it's easier to use absolute file paths. You can always run `pwd` to print out the path of the current directory in order to figure out the absolute path. When this version is ready, run

```python3 my_model.py```

Confirm that there are no import errors, errors with regards to reading or writing to files, or other issues with the skeleton of the script. If using Tensorboard, now is also a good time to check an initial log on localhost to make sure things are being stored correctly. 

When everything looks good, you should be able to continue on to the model run through a batch script without constantly watching or interacting. 

### Notes

There were some issues about finding the file when using relative paths on Satori, so it works best to use `/home/username/` instead of `~`. 

## Running the Model Using a Batch Script

Now that your folders and script are ready, we can run the algorithm with a batch script so we can work on other tasks while it computes. The computation will run in the background on the compute node requested through the script.

A batch script (details [here](https://mit-satori.github.io/satori-workload-manager.html#batch-scripts)) includes information such as job name, output location, error location, number of GPUs, virtual environment location, the script to run, and optionally more. Batch jobs will generally end whenever your script comes to completion or throws an error. 

A lightweight example is below: 

```
#BSUB -L /bin/bash
#BSUB -J "my-job-name"
#BSUB -o "my-job-name_o.%J"
#BSUB -e "my-job-name_e.%J"
#BSUB -n 4
#BSUB -R "span[ptile=4]"
#BSUB -gpu "num=4"
#BSUB -q "normal"

CONDA_ROOT=/home/software/wmlce/1.6.2/
PYTHON_VIRTUAL_ENVIRONMENT=my_env
source ${CONDA_ROOT}/etc/profile.d/conda.sh
conda activate $PYTHON_VIRTUAL_ENVIRONMENT
module load wmlce/1.6.2

cd /home/<username>/<project_dir>
python3 my_model.py
```

The first few lines identify the shell, job name, job output file, and job errorr file. The "_o" (output) and "_e" (error) are necessary to be identified by the Satori processes, but other aspects of the name can be changed. These will be stored in whatever directory you call the script from with the job id concatanated to the file name. The output file additionally contains some general statistics regarding your job. 

The `-n` argument specifies the number of GPUs needed and must be a multiple of 4. It is submitted to the normal queue.

The `CONDA_ROOT` directory given is where modules store the `conda` initialization script. We `source` this file on the compute node (equivalent to our `conda init` earlier, although `conda init` sometimes needs a restart so we avoid it here). If you installed dependencies manually as on the WMLCE page, check out how to access them in a batch script [here](https://mit-satori.github.io/satori-ai-frameworks.html?highlight=ptile#wmlce-testing-ml-dl-frameworks-pytorch-tensorflow-etc-installation). 

It then activates the virtual environment (otherwise we could use module wmlce/1.7.0) and loads the necessary module as gone over earlier. The script finally `cd`s to the project directory and runs the model. 

After saving this or a similar script as `myjob.lsf`, send it to the Satori queue with 

`bsub < myjob.lsf`

To check on the job once sent, go to the portal at **Jobs -> Active Jobs**. Batch jobs will have the name given to them in the script, rather than just `bash` as for interactive jobs. 

It's also helpful to keep watch over error outputs. For this, you can use the follow mode of tail as so 

`tail -f my-job-name_e.id`

This will print out any changes to the end of the file as the job progresses. You can get out of this mode with `Ctrl-C`. Make sure it looks clean and that the script is working!

There are many more possibilities with what to include in Batch Scripts, tailored to what you want your program to run in the background of your other tasks. Some examples are [here]((https://mit-satori.github.io/satori-workload-manager.html#batch-scripts)). This now gives you the capability to run multiple programs at a time, akin to using `screen` on a VM. 


## SSHing from Local Terminal to View localhost
First, make sure you have SSH keys set up on your local environment (a general guide is [here](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2)). 

As mentioned, [ssh](https://mit-satori.github.io/satori-ssh.html?highlight=ssh#ssh-login) with 

`ssh <your_username>@satori-login-001.mit.edu`

It will ask for your password which should be the same as your kerberos password. 

To also forward data sent to a port on the node (for Tensorboard this is port 6006), you can run it with the -L flag as so 

```ssh -L 6006:localhost:6006 <your_username>@satori-login-001.mit.edu```

Now, when you run the Tensorboard command mentioned earlier, localhost:6006 will have your analysis. It forwards anything on data sent to port 6006 on the Satori node to port 6006 on your local machine. Run Tensorboard on the login node (not in an interactive job), as this is where your port forwarding connects to. 

With all of this, you should be good to go with creating your ML pipeline on Satori! 

[Back to Top](#How-to-Create-a-Machine-Learning-Pipeline-through-Satori)

<br>  

[Back to Satori](README.md)