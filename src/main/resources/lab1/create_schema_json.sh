bq show --schema --format=prettyjson logs.logs | sed '1s/^/{"BigQuery Schema":/' | sed '$s/$/}/' > schema.json

cat schema.json

export PROJECT_ID=$(gcloud config get-value project)
gsutil cp schema.json gs://${PROJECT_ID}/