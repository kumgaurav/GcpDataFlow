# Set up environment variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION='us-central1'
export BUCKET=gs://${PROJECT_ID}
export PIPELINE_FOLDER=${BUCKET}
export MAIN_CLASS_NAME=com.mypackage.pipeline.StreamingMinuteTrafficSQLPipeline
export RUNNER=DataflowRunner
export PUBSUB_TOPIC=projects/${PROJECT_ID}/topics/my_topic
export TABLE_NAME=${PROJECT_ID}:logs.minute_traffic

cd $BASE_DIR
mvn compile exec:java \
-Dexec.mainClass=${MAIN_CLASS_NAME} \
-Dexec.cleanupDaemonThreads=false \
-Dexec.args=" \
--project=${PROJECT_ID} \
--region=${REGION} \
--stagingLocation=${PIPELINE_FOLDER}/staging \
--tempLocation=${PIPELINE_FOLDER}/temp \
--runner=${RUNNER} \
--inputTopic=${PUBSUB_TOPIC} \
--tableName=${TABLE_NAME}"


##creating schema
gcloud beta data-catalog entries update \
  --lookup-entry='pubsub.topic.`project-id`.`topic-name`'
  --schema-from-file=schema.json