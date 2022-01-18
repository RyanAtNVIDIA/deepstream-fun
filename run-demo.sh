#!/bin/bash
# file: run-demo.sh

DEEPSTREAM_DOCKER_IMAGE_PATH=deepstream_local.tar.gz

# Check for container image on usb drive
if test -f "$DEEPSTREAM_DOCKER_IMAGE_PATH"; then
	docker load < $DEEPSTREAM_DOCKER_IMAGE_PATH
else
	# If it doesn't exist pull it
	docker pull nvcr.io/nvidia/deepstream:6.0-devel
fi

# Launch the container and run a simple example
xhost + 
docker run --gpus device=0 -it --rm -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY -w /opt/nvidia/deepstream/deepstream/samples/configs/deepstream-app nvcr.io/nvidia/deepstream:6.0-devel deepstream-app -c source4_1080p_dec_infer-resnet_tracker_sgie_tiled_display_int8.txt
