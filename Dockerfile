# Image for loading data into the elastic search

FROM docker.elastic.co/elasticsearch/elasticsearch:7.16.3

ENV discovery.type=single-node

# Finalize elasticsearch installation
ADD config/elasticsearch.yml /etc/elasticsearch/
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-icu

ENV ES_HEAP_SIZE=1g
ENV ES_JAVA_OPTS="-Xms512m -Xmx512m"

ARG DIGITRANSIT_SUBSCRIPTION_KEY
ARG ELASTICSEARCH_HOST

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git unzip python3 python3-pip python3-dev build-essential gdal-bin \
 rlwrap procps emacs curl vim less npm

# Install node
ENV NODE_VERSION=18
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}

# Copy pelias config file
ADD pelias.json /root/pelias.json
RUN mkdir -p /mnt/data

RUN mkdir -p /mnt/tools/scripts
ADD scripts/* /mnt/tools/scripts/
RUN /bin/bash -c "source /mnt/tools/scripts/install-importers.sh"

ENV TOOLS=/mnt/tools
ENV SCRIPTS=/mnt/tools/scripts
ENV DATA=/mnt/data

ENV API_SUBSCRIPTION_QUERY_PARAMETER_NAME=digitransit-subscription-key
ENV API_SUBSCRIPTION_TOKEN=$DIGITRANSIT_SUBSCRIPTION_KEY
ENV ELASTICSEARCH_HOST=$ELASTICSEARCH_HOST
ENV APIURL="https://api.digitransit.fi/"

WORKDIR $DATA

ADD patches/openstreetmap-0001.patch /mnt/tools/openstreetmap
ADD patches/openstreetmap-0002.patch /mnt/tools/openstreetmap
WORKDIR /mnt/tools/openstreetmap
RUN patch -p1 < openstreetmap-0001.patch
RUN patch -p1 < openstreetmap-0002.patch
RUN npm i

ADD patches/pelias-vrk-0001.patch /mnt/tools/pelias-vrk
WORKDIR /mnt/tools/pelias-vrk
RUN patch -p1 < pelias-vrk-0001.patch

WORKDIR $DATA
RUN /mnt/tools/scripts/load-all.sh

RUN start-stop-daemon -S -c 1000 -b -x /usr/share/elasticsearch/bin/elasticsearch -m -p /var/run/elasticsearch.pid \
    && while ! nc -z localhost 9200; do sleep 0.1; done \
    && /mnt/tools/scripts/index-create.sh \
    && . "$NVM_DIR/nvm.sh" && nvm use 18 \
    && /mnt/tools/scripts/index-maps.sh \
    && start-stop-daemon -K -p /var/run/elasticsearch.pid

