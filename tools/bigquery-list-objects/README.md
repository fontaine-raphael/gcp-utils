
# BigQuery Dataset and Object Details Script

## Overview

This script is designed to fetch and list details about datasets and their objects within Google's [BigQuery CLI](https://cloud.google.com/bigquery/docs/reference/bq-cli-reference). It outputs a comprehensive summary of datasets and objects (tables, views, etc.) including their names, locations, creation and last modified times, and, for objects, additional details such as type, number of rows, and total logical bytes used.

## Prerequisites

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install-sdk) installed and configured
- `jq` command-line JSON processor ([download](https://jqlang.github.io/jq/download/))
- Authorization to access the BigQuery project from which details are to be fetched

## Usage

1. Ensure you have the necessary permissions to access the datasets in your BigQuery project.
2. Run the script in a terminal. Ensure to make the file executable using `chmod +x`:
   ```bash
   ./list_objects.sh
   ```
3. The script will start processing all datasets and their objects. Progress will be displayed in the terminal.
4. Upon completion, details will be saved in a TSV file named `datasets_and_objects_details.tsv`.

## Output File Format

The output TSV file `datasets_and_objects_details.tsv` includes the following columns:

- `datasetId`: The Name of the dataset.
- `datasetLocation`: The location of the dataset.
- `datasetCreationTime`: The creation time of the dataset.
- `datasetLastModifiedTime`: The last modified time of the dataset.
- `objectId`: The Name of the object within the dataset.
- `objectType`: The type of the object (e.g., TABLE, VIEW).
- `objectCreationTime`: The creation time of the object.
- `objectLastModifiedTime`: The last modified time of the object.
- `objectNumRows`: The number of rows in the object (if applicable).
- `numTotalLogicalBytes`: The total logical bytes used by the object (if applicable).

*Datetime fields are in GMT-3 time zone.*

## Note

This script is configured to handle a maximum of 1000 datasets and 1000 objects within each dataset. If you have more than 1000 objects, then you can use the `page_token` flag to list all objects using pagination.
