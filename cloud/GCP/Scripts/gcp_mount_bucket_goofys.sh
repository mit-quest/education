#!/bin/bash
# After you add in your access key and secret, this script will install Goofys in the current directory with sufficient permissions and mount your GCP bucket at the given MOUNT_DIR within the current directory. Note that it will override any previous content in ~/.aws/credentials. 
# run with ./mount_bucket_goofys.sh [BUCKET] [MOUNT_DIR]

aws_access_key_id=
aws_secret_access_key=

aws_dir=~/.aws/
aws_creds=~/.aws/credentials


# usage instructions
function Usage() {
    echo "Usage: $0 [BUCKET] [MOUNT_DIR]"
    echo ""
    echo "where:"
    echo "     BUCKET: Bucket to be mounted"
    echo "     MOUNT_DIR: Mount point"
    echo ""
}

# exit if wrong # of args are passed
if [ "$#" -ne 2 ]; then
    Usage
    exit 2
fi

# install goofys & dependencies
sudo apt install fuse
wget https://github.com/kahing/goofys/releases/latest/download/goofys --max-redirect=10 --trust-server-names
chmod 755 goofys

# create credentials file
if [ ! -d $aws_dir ] ; then
	mkdir $aws_dir
fi

if [ -e $aws_creds ] ; then
    rm -rf $aws_creds
fi

cat > $aws_creds <<- EOF
[google]
aws_access_key_id=$aws_access_key_id
aws_secret_access_key=$aws_secret_access_key
EOF

# make mount point if needed
if [ ! -d $2 ] ; then
	mkdir $2
fi

# use goofys to mount bucket
./goofys --profile google --endpoint https://storage.googleapis.com $1 $2
