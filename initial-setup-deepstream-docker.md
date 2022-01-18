# Initial Configuration
The steps below will walk you through setting up a system to run Deepstream inside docker from a fresh install of Ubuntu 18.04.

## Setting up basic functionality 
This section is for initial system functionality tools.

### ssh
SSH is used to remote into the system. To install SSH run the below commands:
```
sudo apt install -y ssh
sudo ufw allow ssh
```
If a non-standard port is needed run the following, substituting your port for 22.
```
sudo ufw allow 22/tcp
```

### Install curl
curl is used to transfer data from a remote server for some installations.
```
sudo apt install -y curl
```

## Setting up NVIDIA drivers
The base Ubuntu system is installed with Nouveau drivers which will cause conflicts with several NVIDIA tools. The following steps will remove the nouvea drivers and install the official NVIDIA drivers.

### Verifying NVIDIA devices
Depending on the GPU and the OS some of the newer GPUs will not show the device name when running ```lspci```
```
sudo update-pciids
```
The ```lspci``` command below will return a list of the connected NVIDIA devices.
```
lspci | grep -i nvidia
```

### Blacklisting nouveau drivers
Create a blacklist file preventing nouveau drivers from running.
```
 sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
 sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
 ```
 Regenerate initramfs
 ```
 sudo update-initramfs -u
 ```
 Note: The system should be rebooted for the updates to take effect.

### Installing the NVIDIA drivers
A more detailed breakdown of the process can be found here <a href="https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html">here</a>.
```
sudo apt-get install -y linux-headers-$(uname -r)
distribution=$(. /etc/os-release;echo $ID$VERSION_ID | sed -e 's/\.//g')
wget https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/cuda-$distribution.pin
sudo mv cuda-$distribution.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/7fa2af80.pub
echo "deb http://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64 /" | sudo tee /etc/apt/sources.list.d/cuda.list
sudo apt-get update
sudo apt-get -y install cuda-drivers
```
Post installation. Note: This command line statement is for CUDA 11.6, if you are trying to install a different version update accordingly.
```
export PATH=/usr/local/cuda-11.6/bin${PATH:+:${PATH}}
/usr/bin/nvidia-persistenced --verbose
```


## Setting up docker
Install base docker
```
curl https://get.docker.com | sh \
  && sudo systemctl start docker \
  && sudo systemctl enable docker
```

Prep for NVIDIA docker
```
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
```

Install nvidia docker
```
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
sudo usermod -a -G docker $USER
```

You should now be able to verify the setup process by running the following and observing the ```nvidia-smi``` output.
```
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```

## Running a basic deepstream demo to verify the system is setup.
First we need to pull the container. This may take some time. 
```
docker pull nvcr.io/nvidia/deepstream:6.0-devel
```
Note: I personally maintain a local copy of the deepstream image as it is ~20GB and can take some time to download.

Enable xhost to display outside of the container
```
xhost +
```

Then running the container with x display configured. This may take some time the first run but a window should appear showing 4 camera feeds.
```
docker run --gpus device=0 -it --rm -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY -w /opt/nvidia/deepstream/deepstream/samples/configs/deepstream-app nvcr.io/nvidia/deepstream:6.0-devel deepstream-app -c source4_1080p_dec_infer-resnet_tracker_sgie_tiled_display_int8.txt
```

The gstreamer cache can be cleared to limit the initial warning messages.
```
rm -rf ${HOME}/.cache/gstreamer-1.0
```
