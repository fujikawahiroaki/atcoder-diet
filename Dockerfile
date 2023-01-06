FROM crystallang/crystal:latest 
MAINTAINER Fujikawa Hiroaki <fhir0aki3@gmail.com>


WORKDIR /usr/local
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl git
RUN curl -Lo bin/shards.gz https://github.com/crystal-lang/shards/archive/refs/tags/v0.17.2.tar.gz; gunzip bin/shards.gz; chmod 755 bin/shards

ADD . /app
WORKDIR /app

RUN shards install

RUN shards build --release 

RUN crystal spec

EXPOSE 8080 

CMD ./bin/atcoder-diet
