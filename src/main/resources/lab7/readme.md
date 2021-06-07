cd ~/ci-cd-for-data-processing-workflow/env-setup
source set_env.sh

If you Don't see a Cloud Composer environment initializing, run the following:

gcloud composer environments create $COMPOSER_ENV_NAME \
    --location $COMPOSER_REGION \
    --zone $COMPOSER_ZONE_ID \
    --machine-type n1-standard-1 \
    --node-count 3 \
    --disk-size 20 \
    --python-version 2
    
    
Run a script to set the variables in the Cloud Composer environment. The variables are needed for the data-processing DAGs.

cd ~/ci-cd-for-data-processing-workflow/env-setup
chmod +x set_composer_variables.sh
./set_composer_variables.sh


In Cloud Shell, export the URL for the bucket as an environment variable:

export COMPOSER_DAG_BUCKET=$(gcloud composer environments describe $COMPOSER_ENV_NAME \
    --location $COMPOSER_REGION \
    --format="get(config.dagGcsPrefix)")
Export the name of the service account that Cloud Composer uses in order to have access to the Cloud Storage buckets:

export COMPOSER_SERVICE_ACCOUNT=$(gcloud composer environments describe $COMPOSER_ENV_NAME \
    --location $COMPOSER_REGION \
    --format="get(config.nodeConfig.serviceAccount)")
    

In Cloud Shell, create Cloud Storage buckets and give the Cloud Composer service account permission to run the data-processing workflows:

cd ~/ci-cd-for-data-processing-workflow/env-setup
chmod +x create_buckets.sh
./create_buckets.sh


In Cloud Shell, push the source-code folder to Cloud Source Repositories:

gcloud source repos create $SOURCE_CODE_REPO
cp -r ~/ci-cd-for-data-processing-workflow/source-code ~/$SOURCE_CODE_REPO
cd ~/$SOURCE_CODE_REPO
git config --global credential.'https://source.developers.google.com'.helper gcloud.sh
git config --global user.email $(gcloud config list --format 'value(core.account)')
git config --global user.name $(gcloud config list --format 'value(core.account)')
git init
git remote add google \
    https://source.developers.google.com/p/$GCP_PROJECT_ID/r/$SOURCE_CODE_REPO
git add .
git commit -m 'initial commit'
git push google master



In Cloud Shell, submit the build pipeline configuration file to create the pipeline in Cloud Build:

cd ~/ci-cd-for-data-processing-workflow/source-code/build-pipeline
gcloud builds submit --config=build_deploy_test.yaml --substitutions=\
REPO_NAME=$SOURCE_CODE_REPO,\
_DATAFLOW_JAR_BUCKET=$DATAFLOW_JAR_BUCKET_TEST,\
_COMPOSER_INPUT_BUCKET=$INPUT_BUCKET_TEST,\
_COMPOSER_REF_BUCKET=$REF_BUCKET_TEST,\
_COMPOSER_DAG_BUCKET=$COMPOSER_DAG_BUCKET,\
_COMPOSER_ENV_NAME=$COMPOSER_ENV_NAME,\
_COMPOSER_REGION=$COMPOSER_REGION,\
_COMPOSER_DAG_NAME_TEST=$COMPOSER_DAG_NAME_TEST



https://landing.google.com/sre/sre-book/chapters/release-engineering/



In Cloud Shell, read the filename of the latest JAR file by printing the Cloud Composer variable for the JAR filename:

export DATAFLOW_JAR_FILE_LATEST=$(gcloud composer environments run $COMPOSER_ENV_NAME \
    --location $COMPOSER_REGION variables -- \
    --get dataflow_jar_file_test 2>&1 | grep -i '.jar')
Use the build pipeline configuration file, deploy_prod.yaml, to create the pipeline in Cloud Build:

cd ~/ci-cd-for-data-processing-workflow/source-code/build-pipeline
gcloud builds submit --config=deploy_prod.yaml --substitutions=\
REPO_NAME=$SOURCE_CODE_REPO,\
_DATAFLOW_JAR_BUCKET_TEST=$DATAFLOW_JAR_BUCKET_TEST,\
_DATAFLOW_JAR_FILE_LATEST=$DATAFLOW_JAR_FILE_LATEST,\
_DATAFLOW_JAR_BUCKET_PROD=$DATAFLOW_JAR_BUCKET_PROD,\
_COMPOSER_INPUT_BUCKET=$INPUT_BUCKET_PROD,\
_COMPOSER_ENV_NAME=$COMPOSER_ENV_NAME,\
_COMPOSER_REGION=$COMPOSER_REGION,\
_COMPOSER_DAG_BUCKET=$COMPOSER_DAG_BUCKET,\
_COMPOSER_DAG_NAME_PROD=$COMPOSER_DAG_NAME_PROD



https://cloud.google.com/composer/docs/how-to/accessing/airflow-cli