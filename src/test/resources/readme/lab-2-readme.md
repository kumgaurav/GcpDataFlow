git clone https://github.com/GoogleCloudPlatform/training-data-analyst.git
# Change directory into the lab
cd 2_Branching_Pipelines/labs

# Download dependencies
mvn clean dependency:resolve
export BASE_DIR=$(pwd)

# Create GCS buckets and BQ dataset
cd $BASE_DIR/../..
source create_batch_sinks.sh

# Generate event dataflow
source generate_batch_events.sh

# Change to the directory containing the practice version of the code
cd $BASE_DIR


#Task 6: Run your pipeline from the command line
# Set up environment variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION='us-central1'
export BUCKET=gs://${PROJECT_ID}
export COLDLINE_BUCKET=${BUCKET}-coldline
export PIPELINE_FOLDER=${BUCKET}
export MAIN_CLASS_NAME=com.mypackage.pipeline.MyPipeline
export RUNNER=DataflowRunner
export INPUT_PATH=${PIPELINE_FOLDER}/events.json
export OUTPUT_PATH=${PIPELINE_FOLDER}-coldline
export TABLE_NAME=${PROJECT_ID}:logs.logs_filtered

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
--inputPath=${INPUT_PATH} \
--outputPath=${OUTPUT_PATH} \
--tableName=${TABLE_NAME}"

##enable build caching
gcloud config set builds/use_kaniko True

##building container
export TEMPLATE_IMAGE="gcr.io/$PROJECT_ID/my-pipeline:latest"
gcloud builds submit --tag $TEMPLATE_IMAGE .


##Then build and stage the actual template:

export TEMPLATE_PATH="gs://${PROJECT_ID}/templates/mytemplate.json"

# Will build and upload the template to GCS
# You may need to opt-in to beta gcloud features
gcloud beta dataflow flex-template build $TEMPLATE_PATH \
  --image "$TEMPLATE_IMAGE" \
  --sdk-language "JAVA" \
  --metadata-file "metadata.json"
  
  
##Running from command line
export PROJECT_ID=$(gcloud config get-value project)
export REGION='us-central1'
export JOB_NAME=mytemplate-$(date +%Y%m%H%M$S)
export TEMPLATE_LOC=gs://${PROJECT_ID}/templates/mytemplate.json
export INPUT_PATH=gs://${PROJECT_ID}/events.json
export OUTPUT_PATH=gs://${PROJECT_ID}-coldline/
export BQ_TABLE=${PROJECT_ID}:logs.logs_filtered

gcloud beta dataflow flex-template run ${JOB_NAME} \
  --region=$REGION \
  --template-file-gcs-location ${TEMPLATE_LOC} \
  --parameters "inputPath=${INPUT_PATH},outputPath=${OUTPUT_PATH},tableName=${BQ_TABLE}" 
  

gcloud beta dataflow flex-template run ${JOB_NAME} \
  --region=$REGION \
  --template-file-gcs-location ${TEMPLATE_LOC} \
  --parameters "inputPath=${INPUT_PATH},outputPath=${OUTPUT_PATH},tableName=${BQ_TABLE}"     
