## 📌 Overview
This is a **Google Cloud Function** (written in Python) that acts as part of an **ETL pipeline** for tracking Google Cloud resource changes.

When a **Cloud Logging Sink** sends resource audit logs (e.g., create/delete) to a **Pub/Sub** topic, this Cloud Function is triggered to:

1. **Extract** resource operation details from the log payload.
2. **Transform** the log data into a structured format.
3. **Load** the processed data into a **BigQuery** dataset and table.

If the dataset or table does not exist, the function will **automatically create them**.

---

## 🛠️ How It Works

### **Trigger**
- **Pub/Sub Topic** that receives GCP audit logs via a **Logging Sink**.

### **Flow**
1. **Receive Event**: The function is triggered by a Pub/Sub message containing a base64-encoded JSON log.
2. **Decode & Parse**: The JSON is decoded and relevant fields are extracted:
   - `resource_name`
   - `resource_type`
   - `operation_type` (e.g., create, delete)
   - `resource_project`
   - `resource_zone`
3. **Check Dataset/Table**:
   - If the dataset does not exist → Create it.
   - If the table does not exist → Create it with the correct schema.
4. **Insert Row**: Append the extracted row to the BigQuery table.

---

## 📂 BigQuery Table Schema
| Column           | Type   | Mode    | Description |
|------------------|--------|---------|-------------|
| resource_name    | STRING | REQUIRED| Name of the GCP resource |
| resource_type    | STRING | REQUIRED| Type of the resource (e.g., compute instance) |
| operation_type   | STRING | REQUIRED| Action performed (create/delete) |
| resource_project | STRING | REQUIRED| GCP project where the resource exists |
| resource_zone    | STRING | REQUIRED| Zone of the resource (or "-" if not applicable) |

---

## 📄 File Description

### `main.py`
- **`main`**: Main Cloud Function entry point.
- **`insert_row_into_table`**: Inserts a row into the BigQuery table.
- **`create_bq_dataset`**: Creates the BigQuery dataset if missing.
- **`create_resources_table`**: Creates the BigQuery table with the correct schema.
- **`check_table_exists`**: Checks if a given table exists in the dataset.

---

