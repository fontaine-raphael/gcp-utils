#!/bin/bash

output_file="datasets_and_objects_details.tsv"
echo -e "datasetId\tdatasetLocation\tdatasetCreationTime\tdatasetLastModifiedTime\tobjectId\tobjectType\tobjectCreationTime\tobjectLastModifiedTime\tobjectNumRows\tnumTotalLogicalBytes" > "$output_file"

# Get all datasets
datasets=$(bq ls --format=prettyjson -n=1000 | jq -r '.[].datasetReference.datasetId')
total_datasets=$(echo "$datasets" | wc -l)
current_dataset=0

# Clear the screen before starting
clear

# Iterate over each dataset
echo "$datasets" | while read dataset_id; do
    ((current_dataset++))

    # Show progress
    echo -ne "\033[2A"
    echo -e "Processing dataset $current_dataset of $total_datasets: $dataset_id"
    percent=$((current_dataset * 100 / total_datasets))
    bar=$(printf '%*s' $((percent / 2)) '' | tr ' ' '=')
    echo -ne "\r[${bar:--}>] $percent%\n"

    # Get dataset details
    dataset_details=$(bq show --format=prettyjson "$dataset_id")
    dataset_location=$(echo "$dataset_details" | jq -r '.location')
    dataset_creation_time=$(TZ='America/Sao_Paulo' date -r $(echo "$(echo "$dataset_details" | jq -r '.creationTime') / 1000" | bc) +"%d/%m/%Y %H:%M:%S")
    dataset_last_modified_time=$(TZ='America/Sao_Paulo' date -r $(echo "$(echo "$dataset_details" | jq -r '.lastModifiedTime') / 1000" | bc) +"%d/%m/%Y %H:%M:%S")

    # List objects (tables, views, etc.) in the dataset
    objects=$(bq ls --format=prettyjson -n=1000 "$dataset_id" | jq -r '.[] | .tableReference.tableId')

    # Check if $objects is not empty before iterating
    if [ -n "$objects" ]; then
        # Iterate over each object
        echo "$objects" | while read object_id; do
            # Get object details
            object_details=$(bq show --format=prettyjson "$dataset_id.$object_id" 2>&1)

            if [[ $object_details == *"BigQuery error"* ]]; then
                echo "Error getting details for $dataset_id.$object_id. Error details: $object_details"
                sleep 5
                object_details=$(bq show --format=prettyjson "$dataset_id.$object_id" 2>&1)
            fi

            object_type=$(echo "$object_details" | jq -r '.type')
            object_creation_time=$(TZ='America/Sao_Paulo' date -r $(echo "$(echo "$object_details" | jq -r '.creationTime') / 1000" | bc) +"%d/%m/%Y %H:%M:%S")
            object_last_modified_time=$(TZ='America/Sao_Paulo' date -r $(echo "$(echo "$object_details" | jq -r '.lastModifiedTime') / 1000" | bc) +"%d/%m/%Y %H:%M:%S")
            object_num_rows=$(echo "$object_details" | jq -r '.numRows')
            numTotalLogicalBytes=$(echo "$object_details" | jq -r '.numTotalLogicalBytes')

            # Save details to file
            echo -e "$dataset_id\t$dataset_location\t$dataset_creation_time\t$dataset_last_modified_time\t$object_id\t$object_type\t$object_creation_time\t$object_last_modified_time\t$object_num_rows\t$numTotalLogicalBytes" >> "$output_file"

        done
    else
        echo -e "$dataset_id\t$dataset_location\t$dataset_creation_time\t$dataset_last_modified_time" >> "$output_file"
    fi
done

echo "Operation completed. Data saved in $output_file"
