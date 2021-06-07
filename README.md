# GcpDataFlow
DataFlowSamples
export PROJECT_ID=$(gcloud info --format='value(config.project)')
export BUCKET=${PROJECT_ID}-ml

git clone https://github.com/GoogleCloudPlatform/data-science-on-gcp/

#Running airflow locally
cd ~/training-data-analyst/courses/data_analysis/lab2

export PATH=/usr/lib/jvm/java-8-openjdk-amd64/bin/:$PATH
cd ~/training-data-analyst/courses/data_analysis/lab2/javahelp
mvn compile -e exec:java \
 -Dexec.mainClass=com.google.cloud.training.dataanalyst.javahelp.Grep
