# Introduction 
Extracts data from a Sics database and writes it to parquet.

## Queries to parquet
All files in the **sql** folder will be process.
1. Read the query from a file
2. Execute the query into a pandas Data Frame
3. Apply a fix on the schema to convert unsigned types to signed counter part. TODO, risk of data loss?
4. Load partition information for the sql file from config.json
5. Write the Data Frame to the **data** folder as a subfolder with the name of the sql file is created.

### Partitioning
In the config.json file you can specify what columns to use for partitioning.
parquet.data_sets["sql_file_name"].partition_on = ["ID1", "ID2" ]

# Setup
1. Create a virtual environment
2. pip install -r requirements.txt
# Running
Use the script in the bin folder to run

# Requirements
* Python 3.9.6

