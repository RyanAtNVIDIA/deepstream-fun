# deepstream-fun
Ryan's collection of resources for building an running deepstream applications

## Pre-reqs
Although this list might not be the exclusive configuration requirements it is what I have tests.
<li>Ubuntu 18.04</li>
<li>NVIDIA driver 495.46</li>
<li>CUDA version 11.5</li>
<li>Docker version 20.10.12</li>
<li>NVIDIA developer account with NGC login configured for docker.</li>

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

