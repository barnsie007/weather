# Generated by IBM TransformationAdvisor
# Thu Nov 16 12:40:29 UTC 2023


FROM icr.io/appcafe/ibm-semeru-runtimes:open-8-jdk-focal AS build-stage

RUN apt-get update && \
    apt-get install -y maven unzip

COPY . /project
WORKDIR /project

#RUN mvn -X initialize process-resources verify => to get dependencies from maven
#RUN mvn clean package

RUN mkdir -p /config/apps && \
    mkdir -p /sharedlibs && \
    cp ./src/main/liberty/config/* /config && \
    cp ./target/*.*ar /config/apps/ && \

    if [ ! -z "$(ls ./src/main/liberty/lib 2>/dev/null)" ]; then \
        cp -r ./src/main/liberty/lib/* /sharedlibs; \
    fi
    

FROM icr.io/appcafe/websphere-liberty:kernel-java8-openj9-ubi

ARG TLS=true


RUN mkdir -p /opt/ibm/wlp/usr/shared/config/lib/global
COPY --chown=1001:0 --from=build-stage /config/ /config/
COPY --chown=1001:0 --from=build-stage /sharedlibs/ /opt/ibm/wlp/usr/shared/config/lib/global

# This script will add the requested XML snippets to enable Liberty features and grow image to be fit-for-purpose using featureUtility.
# Only available in 'kernel-slim'. The 'full' tag already includes all features for convenience.
RUN features.sh

# Add interim fixes (optional)
# COPY --chown=1001:0  interim-fixes /opt/ol/fixes/

# This script will add the requested server configurations, apply any interim fixes and populate caches to optimize runtime
RUN configure.sh

# Upgrade to production license if URL to JAR provided
ARG LICENSE_JAR_URL
RUN \
   if [ $LICENSE_JAR_URL ]; then \
     wget $LICENSE_JAR_URL -O /tmp/license.jar \
     && java -jar /tmp/license.jar -acceptLicense /opt/ibm \
     && rm /tmp/license.jar; \
   fi
