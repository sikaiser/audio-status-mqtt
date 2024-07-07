#!/bin/bash

echo "Installing the audio status monitor service."

# Prompt the user for configuration variables
read -p "Enter a name for your device: " DEVICE_NAME
read -p "Enter the MQTT broker IP: " BROKER_IP
read -p "Enter the MQTT username: " USERNAME
read -s -p "Enter the MQTT password: " PASSWORD
echo

# Define paths
SERVICE_FILE="/etc/systemd/system/audio_status_mqtt.service"
SCRIPT_FILE="/usr/local/bin/audio_status_mqtt.sh"

# Copy the service file
sudo cp audio_status_mqtt.service $SERVICE_FILE

# Replace placeholders in the script with user input
sed -e "s/YOUR_MQTT_BROKER_IP/$BROKER_IP/" \
    -e "s/YOUR_MQTT_USERNAME/$USERNAME/" \
    -e "s/YOUR_MQTT_PASSWORD/$PASSWORD/" \
    -e "s/YOUR_DEVICE_NAME/$DEVICE_NAME/" \
    audio_status_mqtt.sh > temp_audio_status_mqtt.sh

# Copy the modified script file to the appropriate location
sudo cp temp_audio_status_mqtt.sh $SCRIPT_FILE
sudo chmod +x $SCRIPT_FILE

# Reload systemd to recognize the new service
sudo systemctl daemon-reload

# Enable the service to start on boot
sudo systemctl enable audio_status_mqtt.service

# Start the service
sudo systemctl start audio_status_mqtt.service

# Show the service status
sudo systemctl status audio_status_mqtt.service

echo "Installation script finished."
