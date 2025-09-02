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

## 🧠 Future Enhancements
- Add dashboard visualization in Looker Studio/Grafana
- Use Terraform script to create the GCP resources
