This directory covers usage of [Satori](https://mit-satori.github.io), a GPU dense, high-performance Power 9 system developed as a collaboration between MIT and IBM. It currently requires MIT Kerberos credentials for use. The portal login is at <https://satori-portal.mit.edu>. 

### Contents 
[How to Create a Machine Learning Pipeline through Satori](satori_ml_pipeline.md)

<br> 

Satori is a compute cluster meant for very computation intensive projects. Thus, projects with little CPU usage should consider other cloud platforms. It is also important to note that resources on Satori are shared with all other users. This means that projects may have to sit in a queue before use and can be cut off due to time constraints. In the future, it is moving toward the [Slurm Workload Manager](https://slurm.schedmd.com/overview.html) to allocate resource access.

In Satori, there is also no concept of buckets or VM instances. All users files are stored on a shared filesystem, which you can access through a file browser or ssh. To do non-computational tasks, you run commands on a login node. For anything more, you can request an interactive job to access a shell on a compute node or submit a batch script to run background compute tasks.

<br>

[Back to Cloud](../README.md)