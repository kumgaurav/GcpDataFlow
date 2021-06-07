#Basic Etl
git clone https://github.com/GoogleCloudPlatform/training-data-analyst.git

To Build

mvn clean dependency:resolve

# Create GCS buckets and BQ dataset
source create_batch_sinks.sh

# Run a script to generate a batch of web server log events
bash generate_batch_events.sh

# Examine some sample events
head events.json

# Set up environment variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION='us-central1'
export PIPELINE_FOLDER=gs://${PROJECT_ID}
export MAIN_CLASS_NAME=com.mypackage.pipeline.MyPipeline
export RUNNER=DataflowRunner

cd $BASE_DIR
mvn compile exec:java \
-Dexec.mainClass=${MAIN_CLASS_NAME} \
-Dexec.cleanupDaemonThreads=false \
-Dexec.args=" \
--project=${PROJECT_ID} \
--region=${REGION} \
--stagingLocation=${PIPELINE_FOLDER}/staging \
--tempLocation=${PIPELINE_FOLDER}/temp \
--runner=${RUNNER}"


echo $PROJECT_ID
gcloud auth login
gcloud init