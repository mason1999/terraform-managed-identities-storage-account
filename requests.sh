#! /usr/bin/bash

usage() {
    echo -e "\e[93mUsage: Please enter the client id or the object id of the managed identity. Also please enter the name of the storage account in which you want to create a blob and container.\e[37m"
    echo -e "\e[93m./requests.sh -c <Client ID or Object ID> -s <Storage account name>\e[37m"
}


#################### BEGIN SCRIPT ####################

# Can also optionally use the Object ID
client_id=''
storage_account_name=''

while getopts ':c:s:' option; do 
    case $option in
        (c)
            client_id=${OPTARG}
            ;;

        (s)
            storage_account_name=${OPTARG}
            ;;
    esac
done

shift $(( OPTIND - 1 ))

if [[ -z "${client_id}" ]]; then
    usage
    exit 0
fi 

if [[ -z "${storage_account_name}" ]]; then
    usage
    exit 0
fi 

# Create the text file first
echo 'hello world from the blob container.' > 'HelloWorld.txt'

az login --identity --username "${client_id}"
az storage container create --name 'hello-world-container' --account-name "${storage_account_name}" --auth-mode 'login'
az storage blob upload \
    --container-name 'hello-world-container' \
    --file './HelloWorld.txt' \
    --name 'HelloWorldBlob.txt' \
    --account-name "${storage_account_name}" \
    --auth-mode 'login'

# Remove the text file afterards
rm -f 'HelloWorld.txt'
