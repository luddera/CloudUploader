#!/bin/bash

# Check if a file path is provided
if [ -z "$1" ]; then
  echo "Usage: clouduploader /path/to/file.txt"
  exit 1
fi

FILE_PATH=$1

# Check if the file exists
if [ ! -f "$FILE_PATH" ]; then
  echo "File not found: $FILE_PATH"
  exit 1
fi

chmod +x clouduploader.sh

# Define your Azure Storage container name
CONTAINER_NAME=uploader

# Upload the file to Azure Blob Storage
az storage blob upload --account-name $AZURE_STORAGE_ACCOUNT --account-key $AZURE_STORAGE_KEY --container-name $CONTAINER_NAME --file "$FILE_PATH" --name $(basename "$FILE_PATH")

# Check if the upload was successful
if [ $? -eq 0 ]; then
  echo "File uploaded successfully: $FILE_PATH"
else
  echo "Failed to upload file: $FILE_PATH"
fi

# Ensure pv is installed
if ! command -v pv &> /dev/null; then
  echo "pv command not found. Please install pv to enable progress bar."
  exit 1
fi

# Upload the file with a progress bar
pv "$FILE_PATH" | az storage blob upload --account-name $AZURE_STORAGE_ACCOUNT --account-key $AZURE_STORAGE_KEY --container-name <container-name> --name $(basename "$FILE_PATH") --data @-

# Generate a shareable link
BLOB_URL=$(az storage blob url --account-name $AZURE_STORAGE_ACCOUNT --container-name <container-name> --name $(basename "$FILE_PATH") --output tsv)
echo "Shareable link: $BLOB_URL"
