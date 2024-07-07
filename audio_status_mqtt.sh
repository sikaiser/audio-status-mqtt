#!/bin/bash

#This scripts sets the status to "playing" as soon as there is sound.
#But for setting the status to "stopped" it waits a $BUFFER_SIZE amount of seconds.
#When the status is "playing", the status is continuously published to MQTT.
#When the last status was "stopped", no updates are sent until the status changes.

BROKER_IP="YOUR_MQTT_BROKER_IP"
USERNAME="YOUR_MQTT_USERNAME"
PASSWORD="YOUR_MQTT_PASSWORD"
DEVICE_NAME="YOUR_DEVICE_NAME"

STATUS_TOPIC="${DEVICE_NAME}/audio/status"
VOLUME_TOPIC="${DEVICE_NAME}/audio/volume"

BUFFER_SIZE=20 # how many loops of continuous silence until "stopped" is called

previous_status=""
volume_buffer=()

continuous=true

debug=false


while $continuous; do
    #returns both positive and negative values when audio is playing (the closer to 0, the lower the volume)
    volume=$(parec --raw --channels=1 --latency=2 2>/dev/null | od -N2 -td2 | head -n1 | cut -d' ' -f2- | tr -d ' ')

    # Add absolute volume to buffer
    volume_buffer+=(${volume#-})
    if [ ${#volume_buffer[@]} -gt $BUFFER_SIZE ]; then
        volume_buffer=("${volume_buffer[@]:1}")  # Remove the oldest value
    fi

    # Calculate sum of  volumes in buffer
    sum_volume=0
    for v in "${volume_buffer[@]}"; do
        sum_volume=$((sum_volume + v))
    done

    if (($volume != 0)); then
        current_status="playing"
    else
        if (($sum_volume == 0)); then
            current_status="stopped"
        fi
    fi

	# Send update to MQTT while sound is playing or when status has changed.
    if [[ $volume != 0 || "$current_status" != "$previous_status" ]]; then
        mosquitto_pub -h $BROKER_IP -u $USERNAME -P $PASSWORD -t $STATUS_TOPIC -m $current_status
        mosquitto_pub -h $BROKER_IP -u $USERNAME -P $PASSWORD -t $VOLUME_TOPIC -m $volume
        previous_status=$current_status
    fi

    if [ $debug = true ]; then
        continuous=false
    fi
    sleep 1

done

