FROM gcr.io/dataflow-templates-base/java11-template-launcher-base:latest

# Define the Java command options required by Dataflow Flex Templates.
ENV FLEX_TEMPLATE_JAVA_MAIN_CLASS="YOUR-CLASS-HERE"
ENV FLEX_TEMPLATE_JAVA_CLASSPATH="/template/pipeline.jar"

# Make sure to package as an uber-jar including all dependencies.
COPY target/YOUR-JAR-HERE.jar ${FLEX_TEMPLATE_JAVA_CLASSPATH}