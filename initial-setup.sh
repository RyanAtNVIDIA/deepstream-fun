#!/bin/bash
# file: initial-setup.sh

# Install and configure ssh
echo "Installing and configuring ssh"
sudo apt install -y ssh
sudo ufw allow ssh
# sudo ufw allow 22/tcp #uncomment and change port number if something other than 22 is needed

# Install curl
echo "Installing curl"
sudo apt install -y curl

# Verify NVIDIA devices
sudo update-pciids
echo "Verifying NVIDIA devices are present"

if [ -z "lspci | grep -i nvidia"]; then
    echo "No NVIDIA devices found!!!"
    exit 1
else
   echo "NVIDIA Devices found. Blacklisting nouveau drivers."
   source blacklist-nouveau.sh
fi

# Set up nvidia drivers. https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html
sudo apt-get install -y linux-headers-$(uname -r)
distribution=$(. /etc/os-release;echo $ID$VERSION_ID | sed -e 's/\.//g')
wget https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/cuda-$distribution.pin
sudo mv cuda-$distribution.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/7fa2af80.pub
echo "deb http://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64 /" | sudo tee /etc/apt/sources.list.d/cuda.list
sudo apt-get update
sudo apt-get -y install cuda-drivers

#Post installation https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#post-installation-actions
this_cuda_version=$(nvidia-smi | grep CUDA | cut -d ":" -f 3 | cut -d " " -f 2)
export PATH=/usr/local/cuda-$this_cuda_version/bin${PATH:+:${PATH}}
/usr/bin/nvidia-persistenced --verbose

# Setup for containers
curl https://get.docker.com | sh \
  && sudo systemctl start docker \
  && sudo systemctl enable docker

distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update

sudo apt-get install -y nvidia-docker2

sudo systemctl restart docker

sudo usermod -a -G docker $USER

# Install docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

read -n1 -p 'Would you like to reboot now? [y,n]' userinput
if [[ $userinput == Y || $userinput == y ]]; then
    sudo reboot
else
    echo exiting
    exit 0
fi


