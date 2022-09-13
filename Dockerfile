# the precomipiled version of node 18 is linked to glibc 2.28
# the Lambda environment as of 04/23/2022 only has glibc 2.26
# so we build our own version of node 18 linked to glibc 2.26

FROM lambci/lambda:build-provided.al2 AS builder

RUN yum install gcc10-c++ -y
ENV CXX=/usr/bin/gcc10-g++

WORKDIR "/root"
RUN curl -O https://nodejs.org/dist/v18.0.0/node-v18.0.0.tar.gz
RUN tar xf node-v18.0.0.tar.gz 

WORKDIR "/root/node-v18.0.0"
RUN ./configure
RUN make -j4

WORKDIR "/root"
RUN cp ./node-v18.0.0/out/Release/node .
RUN curl -O https://raw.githubusercontent.com/rrainn/aws-lambda-custom-node-runtime/master/templates/node_runtime.js

COPY bootstrap .

RUN zip node18lambdaruntime.zip bootstrap node node_runtime.js


FROM alpine:3.15.4

COPY --from=builder /root/node18lambdaruntime.zip /root
WORKDIR "/root"