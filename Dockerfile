FROM ubuntu:18.04

RUN apt update; apt upgrade -y

RUN apt install -y vim \
                   git \
                   curl \
                   clang \
                   cmake \
                   libtool \
                   autoconf \
                   zlib1g-dev \
                   pkg-config \
                   libc++-dev \
                   python3-dev \
                   python3-pip \
                   libudev-dev \
                   libgtest-dev \
                   libgflags-dev \
                   build-essential \
                   libusb-1.0.0-dev \
                   software-properties-common

RUN cd /root && \
    git clone -b $(curl -L https://grpc.io/release) https://github.com/grpc/grpc && \
    cd grpc && \
    git submodule update --init && \
    mkdir -p cmake/build && \
    cd cmake/build && \
    cmake ../.. && \
    make -j$(nproc) && \
    make install && \
    ldconfig

RUN cd /tmp/grpc && \
    cd thrid_party/protobuf && \
    make install & \
    ldconfig

RUN add-apt-repository -y ppa:deadsnakes/ppa

RUN apt update

RUN apt install -y python3.5 libpython3.5-dev

RUN python3.5 -m pip install -U pip

RUN python3.5 -m pip install numpy==1.11.3 \
                            scikit-learn==0.18.1 \
                            scipy==0.18.1 \
                            tensorflow==0.12.1 \
                            snet-cli

#RUN git clone https://github.com/uclnlp/fakenewschallenge /root/uclnlp
RUN git clone -b snet-service https://github.com/dagims/fakenewschallenge /root/uclnlp

WORKDIR /root/uclnlp

RUN python3.5 -m grpc_tools.protoc \
              -I. \
              --python_out=. \
              --grpc_python_out=. \
              ./service_spec/uclnlpfnc.proto
