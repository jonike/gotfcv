FROM ubuntu:14.04

# Install depends
ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No
ENV LANG en_US.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        libc6-dev \
        curl \
        g++ \
        gcc \
		zip \
		unzip \
		make \
		cmake \
		git \
		wget \
		yasm \
		pkg-config \
		libavcodec-dev \
		libavformat-dev \
		libswscale-dev \
		libpq-dev \
		libtbb2 \
		libtbb-dev \
		libjpeg-dev \
		libpng-dev \
		libtiff-dev \
		libjasper-dev \
		libdc1394-22-dev \
		software-properties-common \
	    && rm -rf /var/lib/apt/lists/*

# Install GoLang 1.10.2
ENV GOVERSION 1.10.2
ENV GOROOT /opt/go
ENV GOPATH /go

RUN cd /opt \
    && wget https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz \
    && tar zxf go${GOVERSION}.linux-amd64.tar.gz && rm go${GOVERSION}.linux-amd64.tar.gz \
    && ln -s /opt/go/bin/go /usr/bin/ \
    && mkdir $GOPATH

WORKDIR /

# Install JasPer 2.0.14
# RUN mkdir /tmp/jasper \
#    && mkdir /tmp/jasper/build \
#	&& cd /tmp/jasper \
#	&& wget -O jasper.zip https://github.com/mdadams/jasper/archive/version-2.0.14.zip \
#	&& unzip jasper.zip \
#	&& cd /tmp/jasper/jasper-version-2.0.14 \
#	&& cmake -G "Unix Makefiles" -H/tmp/jasper/jasper-version-2.0.14 -B/tmp/jasper/build \
#	        -DCMAKE_INSTALL_PREFIX=/usr/local \
#	&& cd /tmp/jasper/build \
#	&& make \
#	&& make install \
#	&& cd ~ \
#   && rm -rf /tmp/jasper

# Install OpenCV
ENV OPENCV_VERSION 3.4.1

RUN mkdir /tmp/opencv \
	&& cd /tmp/opencv \
	&& wget -O opencv.zip https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
	&& unzip opencv.zip \
	&& wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip \
	&& unzip opencv_contrib.zip

ENV OPENCV_CPU_DISABLE SSSE3,AVX,AVX2,POPCNT,SSE4.1,SSE4.2

RUN cd /tmp/opencv/opencv-${OPENCV_VERSION} \
	&& mkdir build \
	&& cd build \
	&& cmake -D CMAKE_BUILD_TYPE=RELEASE \
	         -D CMAKE_INSTALL_PREFIX=/usr/local \
	         -D OPENCV_EXTRA_MODULES_PATH=/tmp/opencv/opencv_contrib-${OPENCV_VERSION}/modules \
	         -D BUILD_DOCS=OFF BUILD_EXAMPLES=OFF \
	         -D BUILD_TESTS=OFF \
	         -D WITH_CUDA=OFF \
             -D ENABLE_AVX=OFF \
             -D WITH_OPENGL=ON \
             -D WITH_OPENCL=ON \
             -D WITH_IPP=ON \
             -D WITH_TBB=ON \
             -D WITH_EIGEN=ON \
             -D WITH_V4L=ON \
             -D BUILD_TIFF=ON \
	         -D BUILD_PERF_TESTS=OFF \
	         -D BUILD_opencv_java=OFF \
	         -D BUILD_opencv_python=OFF \
	         -D BUILD_opencv_python2=OFF \
	         -D CMAKE_BUILD_TYPE=RELEASE \
	         -D CPU_BASELINE=SSE,SSE2,SSE3 \
	         -D BUILD_opencv_python3=OFF .. \
	&& make -j4 \
	&& make install \
	&& echo "/usr/local/lib/x86_64-linux-gnu" > /etc/ld.so.conf.d/opencv.conf
	&& ldconfig	\
	&& cd ~ \
    && rm -rf /tmp/opencv

# Install TensorFlow C library
RUN curl -L \
   "https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-x86_64-1.8.0.tar.gz" | \
   tar -C "/usr/local" -xz \
   && ldconfig

# Hide some warnings
ENV TF_CPP_MIN_LOG_LEVEL 2