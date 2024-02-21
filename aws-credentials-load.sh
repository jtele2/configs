#!/bin/bash

# Prompt for new AWS Access Key ID and Secret Access Key
read -p "Enter your AWS Access Key ID: " aws_access_key_id
read -p "Enter your AWS Secret Access Key: " aws_secret_access_key

# Backup the current AWS credentials file
cp ~/.aws/credentials ~/.aws/credentials.backup

# Update AWS credentials for the default profile
aws configure set aws_access_key_id "$aws_access_key_id" --profile default
aws configure set aws_secret_access_key "$aws_secret_access_key" --profile default

echo "AWS credentials updated successfully."
