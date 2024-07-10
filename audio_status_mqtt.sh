#!/bin/bash

#This scripts sets the status to "playing" as soon as there is sound.
#After DELAY_PAUSED seconds of no sound, it sets the status to "paused".
#And after DELAY_STOPPED seconds of no sound, it sets the status to "stopped".
#When the status is "playing", the status is continuously published to MQTT.
#During the DELAY_PAUSED period, the status "playing" is not updated.
#The statuses "paused" and "stopped" are sent only once.

BROKER_IP="YOUR_MQTT_BROKER_IP"
USERNAME="YOUR_MQTT_USERNAME"
PASSWORD="YOUR_MQTT_PASSWORD"
DEVICE_NAME="YOUR_DEVICE_NAME"

STATUS_TOPIC="${DEVICE_NAME}/audio/status"
VOLUME_TOPIC="${DEVICE_NAME}/audio/volume"

DELAY_PAUSED=20 # how many loops of continuous silence until "paused" is sent
DELAY_PAUSED=120 # how many loops of continuous silence until "stopped" is sent

count_no_volume=0

continuous=true

debug=false


while $continuous; do
    #returns both positive and negative values when audio is playing (the closer to 0, the lower the volume)
    volume=$(parec --raw --channels=1 --latency=2 2>/dev/null | od -N2 -td2 | head -n1 | cut -d' ' -f2- | tr -d ' ')


    if (($volume != 0)); then
        count_no_volume=0
    else
        count_no_volume=$((count_no_volume+1))
    fi

    case $count_no_volume in
        0)
            mosquitto_pub -h $BROKER_IP -u $USERNAME -P $PASSWORD -t $STATUS_TOPIC -m "playing"
            mosquitto_pub -h $BROKER_IP -u $USERNAME -P $PASSWORD -t $VOLUME_TOPIC -m $volume
            ;;

        $DELAY_PAUSED)
            mosquitto_pub -h $BROKER_IP -u $USERNAME -P $PASSWORD -t $STATUS_TOPIC -m "paused"
            mosquitto_pub -h $BROKER_IP -u $USERNAME -P $PASSWORD -t $VOLUME_TOPIC -m $volume
            ;;

        $DELAY_STOPPED)
            mosquitto_pub -h $BROKER_IP -u $USERNAME -P $PASSWORD -t $STATUS_TOPIC -m "stopped"
            mosquitto_pub -h $BROKER_IP -u $USERNAME -P $PASSWORD -t $VOLUME_TOPIC -m $volume
            ;;
    esac

    if [ $debug = true ]; then
        continuous=false
    fi
    sleep 1

done
