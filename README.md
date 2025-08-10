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
| resource_name | STRING   | Name of GCP service |
| resource_type | STRING   | Type of service eg. compute |
| operation_type| STRING   | Type of operation (CREATE or DELETE) |
| resource_project| STRING | Project in which the resource was created or deleted. |
| resource_zone | STRING   | Zone of service |


## 🚀 Deployment Steps

   ```bash
   gcloud pubsub topics create error-logs
