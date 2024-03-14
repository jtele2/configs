#!/usr/bin/env python3

"""
TODO: 
  - Update the check with the boto3 waiters
"""

# Standard Library
import os
import sys
import time

# Third Party
import boto3


def is_venv():
    """Check if script is running in the expected virtual environment."""
    venv_path = os.path.join(os.getcwd(), "venv")
    return sys.prefix.startswith(venv_path)


def update_ssh_config(new_ip):
    ssh_config_path = os.path.expanduser("~/.ssh/config")
    with open(ssh_config_path, "r") as file:
        lines = file.readlines()

    found_host = False
    for i, line in enumerate(lines):
        if line.strip() == "Host AcgPractice":
            found_host = True
        if found_host and line.strip().startswith("HostName"):
            lines[i] = f"    HostName {new_ip}\n"
            break

    with open(ssh_config_path, "w") as file:
        file.writelines(lines)
    print("SSH config for AcgPractice updated with new IP:", new_ip)


def check_instance_status_and_update_ssh():
    if not is_venv():
        print("This script is not running in the expected virtual environment.")
        print("Please activate the venv located at ./venv and try again.")
        sys.exit(1)

    ec2 = boto3.client("ec2", region_name="us-east-1")

    all_ready = False
    while not all_ready:
        response = ec2.describe_instances()

        for reservation in response["Reservations"]:
            for instance in reservation["Instances"]:
                instance_id = instance["InstanceId"]
                instance_state = instance["State"]["Name"]
                if instance_state == "running":
                    public_ip = instance.get("PublicIpAddress")
                    if public_ip:
                        update_ssh_config(public_ip)
                        all_ready = True
                        break
            if all_ready:
                break

        if not all_ready:
            print("Waiting for instances to be ready...")
            time.sleep(0.5)
        else:
            print("\nInstance is ready for SSH connection.")


if __name__ == "__main__":
    check_instance_status_and_update_ssh()
