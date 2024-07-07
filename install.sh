#!/bin/bash

echo "Installing the audio status monitor service."

# Prompt the user for configuration variables
read -p "Enter the MQTT broker IP: " BROKER_IP
read -p "Enter the MQTT username: " USERNAME
read -s -p "Enter the MQTT password: " PASSWORD
read -s -p "Enter a name for your device: " DEVICE_NAME
echo

# Define paths
SERVICE_FILE="/etc/systemd/system/audio_status_mqtt.service"
SCRIPT_FILE="/usr/local/bin/audio_status_mqtt.sh"

# Define GitHub URL for raw files
GITHUB_REPO="https://raw.githubusercontent.com/sikaiser/audio-status-mqtt/main/"

# Download the service file
sudo curl -s -L $GITHUB_REPO/audio_status_mqtt.service > $SERVICE_FILE

# Replace placeholders in the script with user input
sudo curl -s -L $GITHUB_REPO/audio_status_mqtt.sh | sed -e "s/YOUR_HOME_ASSISTANT_IP/$BROKER_IP/" \
    -e "s/YOUR_MQTT_USERNAME/$USERNAME/" \
    -e "s/YOUR_MQTT_PASSWORD/$PASSWORD/" \
    -e "s/YOUR_DEVICE_NAME/$DEVICE_NAME/" \
    > $SCRIPT_FILE

# Make the script file executable
sudo chmod +x $SCRIPT_FILE

# Reload systemd to recognize the new service
sudo systemctl daemon-reload

# Enable the service to start on boot
sudo systemctl enable audio_status_mqtt.service

# Start the service
sudo systemctl start audio_status_mqtt.service

echo "Installation script ended."