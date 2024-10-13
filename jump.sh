#! /usr/bin/bash

terraform_output=$(terraform output -json)

ip_address=$(echo $terraform_output | jq --raw-output '.public_ip_address.value')
username=$(echo $terraform_output | jq --raw-output '.username.value')
password=$(echo $terraform_output | jq --raw-output '.password.value')

echo "The password is: ${password}"

ssh "${username}@${ip_address}"
