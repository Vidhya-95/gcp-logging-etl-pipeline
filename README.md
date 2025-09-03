# GCP Logging ETL Pipeline

## 📌 Overview
This project is a **real-time ETL pipeline** built on **Google Cloud Platform** to monitor and analyze audit logs from various GCP services.  
It extracts logs from **Cloud Logging (Audit)**, transforms them via a **Cloud Function** (Python), and loads the processed data into **BigQuery** for storage and analysis.

## 🛠️ Architecture
Cloud Logging (Audit logs) <br>
↓ <br>
Logging Sink (Filter)<br>
↓<br>
Pub/Sub Topic <br>
↓<br>
Cloud Function (Python - parse & transform)<br>
↓<br>
BigQuery Table


## 🔧 Services Used
- **Cloud Logging Sink** – Filters logs and routes them to Pub/Sub
- **Pub/Sub** – Decouples logging and processing
- **Cloud Functions (Python)** – Parses logs, extracts metadata, and formats data
- **BigQuery** – Stores structured logs for analytics

## 📂 BigQuery Table Schema
| Column       | Type     | Description |
|--------------|----------|-------------|
| resource_name | STRING   | Name of GCP resource |
| resource_type | STRING   | Type of service eg. compute |
| operation_type| STRING   | Type of operation (CREATE or DELETE) |
| resource_project| STRING | Project in which the resource was created or deleted. |
| resource_zone | STRING   | Zone of resource |

## **Prerequisites** 
**1. Enable the APIs :**
- Cloud Pub/Sub API
- Eventarc API
- BigQuery API
- Cloud Functions API
- Cloud Logging API
  
**2. Make sure you or your Service Account (recommended) have the following permissions before you deploy the resources:**
- BigQuery Data Editor
- Cloud Build Logging Service Agent
- Cloud Build Service Account
- Cloud Functions Developer
- Cloud Run Builder
- Logging Admin
- Logs Configuration Writer
- Pub/Sub Editor
- Service Account User  

## 🚀 Deployment Steps
1. **Create a Pub/Sub topic** 
   ```bash
   gcloud pubsub topics create audit-logs
   
2. **Create Logging Sink**
   ```bash
   gcloud logging sinks create audit-log-sink \
    pubsub.googleapis.com/projects/**PROJECT_ID**/topics/audit-logs \
    --log-filter='logName="projects/**PROJECT_ID**/logs/cloudaudit.googleapis.com%2Factivity" AND protoPayload.methodName:("create" OR "delete" OR "insert") AND operation.last="true"'

3. **Deploy the Cloud Function**  
   ```bash
   gcloud functions deploy process_audit_logs \
    --runtime python313 \
    --trigger-topic audit-logs \
    --entry-point main \
    --region us-central1 \
    --source **<PATH_TO_PYTHON_CODE>**

**NOTE :** [Python code available here](gcp-error-etl-pipeline)
## Useful Links:
- [Create a service account and assign roles](https://cloud.google.com/iam/docs/service-accounts-create#gcloud)
  
<br>

# Cloud Audit Log Processing with Terraform
We can use Terraform to deploy a solution on Google Cloud Platform that processes audit logs in real-time. It sets up a Pub/Sub topic, a logging sink to forward audit logs to the topic, a Cloud Storage bucket for the function's source code, and a Cloud Function to process the logs.

## ⚙️ Terraform Configuration
The project consists of three main Terraform files:

`variables.tf`: Defines all the variables used in the configuration, including project_id, topic_name, bucket_name, and others. This file is where you will configure your project-specific values.  
`main.tf`: Contains the resource definitions for the GCP services, including the Pub/Sub topic, logging sink, Cloud Storage resources, and the Cloud Function.  
`outputs.tf` : Shows the names of the resources created such as topic_name, bucket_name, and others.  

## 🚀 Deployment Steps
Follow these steps to deploy the resources to your GCP project.

### Prerequisites
**Terraform CLI**: Ensure you have the Terraform command-line interface installed.  
**Google Cloud SDK**: The gcloud command-line tool must be installed and authenticated to your GCP account.  
**Cloud Function Source Code**: You must have your Cloud Function's source code zipped into a file. [Zipped python source code](gcp-error-etl-pipeline/process_audit_logs_function-source.zip)   

**1. Configure Variables**     
Before you can apply the configuration, you need to update two key variables.  
- Open the `variables.tf` file and set the default value of the project_id variable to your desired GCP Project ID.  
```
variable "project_id" {
          default     = "<PROJECT_ID>" # Add your desired project id.
          description = "This a GCP Project Id where all the resources will be created"
        }
```
      
- Open the main.tf file and update the source attribute within the google_storage_bucket_object resource. This should be the local path to your zipped Cloud Function source code.  
```
resource "google_storage_bucket_object" "tf_object" {
          name   = var.object_name
          bucket = google_storage_bucket.tf_bucket.name
          source = "<PATH_TO_ZIPPED_SOURCE_CODE>" # Add path to the zipped function source code e.g.: "/gcp-error-etl-pipeline/process_audit_logs_function-source.zip"
        }
```
**2. Run Terraform Commands** 
Navigate to the directory containing your .tf files and run the following commands in order:
  1. Initialize Terraform: This command downloads the necessary provider plugins.  
     ```terraform init```

  2. Generate a Plan: This command creates an execution plan, showing you exactly what resources will be created.  
    ```terraform plan```  

  3. Apply the Configuration: This command applies the plan and creates the resources in your GCP project. Type `yes` when prompted to confirm.  
     ```terraform apply```

# 🛠️ Resources Created  
This Terraform configuration will provision the following resources in your project:

`google_pubsub_topic`: A new Pub/Sub topic to serve as the destination for the logging sink.  
`google_logging_project_sink`: A logging sink that filters for create, delete, and insert events from the Cloud Audit Logs and routes them to the Pub/Sub topic.  
`google_storage_bucket`: A new Cloud Storage bucket to store the zipped source code of your Cloud Function.  
`google_storage_bucket_object`: An object within the bucket that holds your zipped source code.  
`google_cloudfunctions2_function`: A new 2nd Gen Cloud Function that is triggered whenever a new message is published to the Pub/Sub topic.  


