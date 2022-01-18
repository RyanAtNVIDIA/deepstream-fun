# deepstream-fun
Ryan's collection of resources for building an running deepstream applications. These tools are not intended to replace <a href="https://docs.nvidia.com/metropolis/deepstream/dev-guide/">the Offical NVIDIA Deepstream documentiation</a> but rather to aid in setting up a demo system as fast as possible without the need to understand the underlying system components.

I've included several methods to get up and running on NVIDIA deepstream.
<li>Automated Script for running Deepstream inside Docker.</li>
<li>Guided instruction for running Deepstream inside Docker.</li>
<li>TODO: Automated scripts for running Deepstream on bare metal.</li>
<li>TODO: Guided instructions for running Deepstream on bare metal.</li>

As of now, these scripts an instructions are using Ubuntu 18.04. If there is demand for other variants please reach out to me at rsimpson@nvidia.com.

## Pre-reqs
Starting with a fresh install of Ubuntu 18.04.




## Verification that everything is ready
To verify the system should be able to run the deepstream app container, run the following:
``` 
sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```
The output should show the nvidia-smi output.

Once confirmed the system is ready to run nvidia containers we can run a sample deepstream app by first pulling the container
```
docker pull nvcr.io/nvidia/deepstream:6.0-devel
```

Enabling xhost to display
```
xhost +
```
Then running the container with x display configured
```
docker run --gpus device=0 -it --rm -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY -w /opt/nvidia/deepstream/deepstream/samples/configs/deepstream-app nvcr.io/nvidia/deepstream:6.0-devel deepstream-app -c source4_1080p_dec_infer-resnet_tracker_sgie_tiled_display_int8.txt
```

## Clearing cache
```
rm -rf ${HOME}/.cache/gstreamer-1.0
```


## Running Graph composer
Not yet tested.
```
docker pull nvcr.io/nvidia/deepstream:6.0-devel
xhost +
docker run -it --entrypoint /bin/bash --gpus all --rm --network=host -e DISPLAY=:0 -v /tmp/.X11-unix/:/tmp/.X11-unix --privileged -v /var/run/docker.sock:/var/run/docker.sock nvcr.io/nvidia/deepstream:6.0-devel
composer
```
