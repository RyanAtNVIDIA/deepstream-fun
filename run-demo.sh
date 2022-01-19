#!/bin/bash
# file: run-demo.sh

DEEPSTREAM_DOCKER_IMAGE_PATH=deepstream_local.tar.gz
DEEPSTREAM_DOCKER_IMAGE="nvcr.io/nvidia/deepstream:6.0-devel"
DEEPSTREAM_DEVICES="device=0"
DEEPSTREAM_DISPLAY_CMD="-v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY"
DEEPSTREAM_WORKING_DIR_CMD="-w /opt/nvidia/deepstream/deepstream/samples/configs/deepstream-app"
DEEPSTREAM_APP_CMD="deepstream-app -c"
DOCKER_RUN_CMD="docker run --gpus $DEEPSTREAM_DEVICES -it --rm $DEEPSTREAM_DISPLAY_CMD $DEEPSTREAM_WORKING_DIR_CMD $DEEPSTREAM_DOCKER_IMAGE"

DEMO_1_CONFIG="source30_1080p_dec_infer-resnet_tiled_display_int8.txt"
DEMO_2_CONFIG=source30_1080p_dec_preprocess_infer-resnet_tiled_display_int8.txt
DEMO_3_CONFIG="source4_1080p_dec_infer-resnet_tracker_sgie_tiled_display_int8.txt"

# Demos not yet tested
#source1_usb_dec_infer_resnet_int8.txt
#source4_1080p_dec_infer-resnet_tracker_sgie_tiled_display_int8_gpu1.txt

# Check if container is already on the machine
printf "\nChecking for deepstream container."
if [ -z "$(docker images | grep nvcr.io/nvidia/deepstream)" ]; then
    printf "\nNo deepstream container found!"
    container_needed=true
else
    printf "Docker container found."
    container_needed=false
fi


if $container_needed; then
    printf "\nLooking for local backup of contianer image."
    # Check for container image on usb drive
    if test -f "$DEEPSTREAM_DOCKER_IMAGE_PATH"; then
	docker load < $DEEPSTREAM_DOCKER_IMAGE_PATH
        printf "\ntar backup found."
        printf "\nLoading docker from tar file."
    else
	# If it doesn't exist pull it
        printf "\nNo tar file found. Pulling from docker."
	docker pull nvcr.io/nvidia/deepstream:6.0-devel
    fi
else
    printf "\nContainer is present.\n"
fi



while $request_input 
do

    printf "\nPlease select a demo from the following list:\n"
    printf "1) Tiled display with 30 feeds at 1080p infering with Resnet at int8.\n"
    printf "2) Tiled display with 30 feeds at 1080p infering with Resnet at int8 with preprocessing.\n"
    printf "3) Tiled display with 4 feeds at 1080p infering with Resnet at int8.\n"
    printf "4) Run container in interactive mode without demo.\n"
    printf "9) exit.\n"
    read userInput

    case $userInput in
      1)
        printf "\nRunning demo 1.\n"
        cmd_str="$DOCKER_RUN_CMD $DEEPSTREAM_APP_CMD $DEMO_1_CONFIG"
        request_input=false
        ;;
      2)
        printf "\nRunning demo 2.\n"
        cmd_str="$DOCKER_RUN_CMD $DEEPSTREAM_APP_CMD $DEMO_2_CONFIG"
        request_input=false
        ;;
      3)
        printf "\nRunning demo 3.\n"
        cmd_str="$DOCKER_RUN_CMD $DEEPSTREAM_APP_CMD $DEMO_3_CONFIG"
        request_input=false
        ;;
      4)
        printf "\nRunnning Deepstream container without demo.\n"
        cmd_str="$DOCKER_RUN_CMD"
        request_input=false
        ;;
      9)
        printf "\nExiting\n"
        cmd_str=""
        request_input=false
        ;;
      *)
        printf "\n\nPlease select one of the available demos.\n"
        cmd_str=""       
        ;;
    esac
done

# Setup xhost to allow display outside of container
xhost +

# Run the cmd string
$cmd_str
