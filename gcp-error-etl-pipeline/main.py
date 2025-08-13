import base64
import functions_framework
import json
from google.cloud import bigquery


client = bigquery.Client()
dataset_name =""
table_name = ""
list_of_datasetid = []
list_of_tables =[]
project = client.project


# Triggered from a message on a Cloud Pub/Sub topic.
@functions_framework.cloud_event
def main(cloud_event):
    dataset_name = "resourceDataset"
    table_name = "resourceTable"
    json_data = json.loads(base64.b64decode(cloud_event.data["message"]["data"]))

    print("----------------------RESOURCE DETAILS-------------------------------------------------------")
    operation_type = json_data['protoPayload']['methodName'].split('.')[-1]
    resource_name = json_data['protoPayload']['resourceName'].split('/')[-1]
    resource_type = json_data['resource']['type']
    resource_project = json_data['resource']['labels']['project_id']
    if json_data['resource']['labels']['zone']:
        resource_zone=json_data['resource']['labels']['zone']
    else:
        resource_zone = "-"

    row_to_insert= [{'resource_name':resource_name , 'resource_type': resource_type , 'operation_type':operation_type,
                     'resource_project': resource_project, 'resource_zone' :resource_zone}]

       
    datasets = list(client.list_datasets())
    if datasets:
        for dataset in datasets:
            list_of_datasetid.append(dataset.dataset_id)
        print("LIST OF DATASET {}".format(list_of_datasetid))
    else:
        print("{} project does not contain any datasets.".format(project))

    if dataset_name in list_of_datasetid:
        print("DATASET ALREADY EXISTS")
        if check_table_exists(dataset_name,table_name):
            print("TABLE EXISTS MAKE AN ENTRY")
            insert_row_into_table(dataset_name,table_name,row_to_insert)
        else:
            create_resources_table(dataset_name,table_name)
            insert_row_into_table(dataset_name,table_name,row_to_insert)

    else :
        create_bq_dataset(dataset_name)
        if check_table_exists(dataset_name,table_name):
            print("TABLE EXISTS MAKE AN ENTRY")
            insert_row_into_table(dataset_name,table_name,row_to_insert)
        else:
            create_resources_table(dataset_name,table_name)
            insert_row_into_table(dataset_name,table_name,row_to_insert)


    print("====================================END=====================================================")
    return "OK"


def insert_row_into_table(dataset_name,table_name,row_to_insert):
    table_ref = "{}.{}.{}".format(project,dataset_name,table_name)
    errors = client.insert_rows_json(table_ref, row_to_insert)

    if errors == []:
        print("New rows have been added successfully.")
    else:
        print(f"Encountered errors while inserting rows: {errors}")


def create_bq_dataset(dataset_name):
    
    # TODO(developer): Set dataset_id to the ID of the dataset to create.
    dataset_id = "{}.{}".format(project,dataset_name)

    # Construct a full Dataset object to send to the API.
    dataset = bigquery.Dataset(dataset_id)

    # TODO(developer): Specify the geographic location where the dataset should reside.
    dataset.location = "US"

    dataset = client.create_dataset(dataset, timeout=30)  # Make an API request.
    print("Created dataset {}.{}".format(project, dataset.dataset_id))
    

def create_resources_table(dataset_name,table_name):
    table_id = "{}.{}.{}".format(project,dataset_name,table_name)
    schema = [
    bigquery.SchemaField("resource_name", "STRING", mode="REQUIRED"),
    bigquery.SchemaField("resource_type", "STRING", mode="REQUIRED"),
    bigquery.SchemaField("operation_type", "STRING", mode="REQUIRED"),
    bigquery.SchemaField("resource_project", "STRING", mode="REQUIRED"),
    bigquery.SchemaField("resource_zone", "STRING", mode="REQUIRED")
    ]

    table = bigquery.Table(table_id, schema=schema)
    table = client.create_table(table)  # Make an API request.
    print(
        "Created table {}.{}.{}".format(table.project, table.dataset_id, table.table_id)
    )


def check_table_exists(dataset_name,table_name):
    tables = client.list_tables(dataset_name)  # Make an API request.

    print("Tables contained in '{}':".format(dataset_name))
    for table in tables:
        #print("{}.{}.{}".format(table.project, table.dataset_name, table.table_id))
        list_of_tables.append(table.table_id)
    print("LIST OF TABLES : {}".format(list_of_tables))

    if table_name in list_of_tables:
        return True
    else:
        return False



