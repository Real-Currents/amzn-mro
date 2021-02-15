FROM docker.io/realcurrents/amzn-mro-3.5.1:origin

ENV LD_LIBRARY_PATH /var/task/lib64:/usr/local/lib
ENV PATH /var/task/adam/bin:/var/task/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV REXEC R
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

RUN cd /var/task && \
    curl -o mro-3.5.1.zip https://real-currents.s3-us-west-1.amazonaws.com/r/mro-3.5.1.zip && \
    yum groupinstall -y "Development Tools" && \
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm && \
    yum -y install https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm && \
    yum -y update && \
    yum install -y armadillo armadillo-devel cmake libcurl-devel libgit2-devel less freeglut-devel gmp-devel \
        gdal-devel geos-devel jq-devel protobuf-devel proj-devel proj-nad proj-epsg v8-devel \
        ImageMagick-c++-devel libcairo libcurl libcurl-devel libjpeg-turbo-devel libpng12 libpng-devel libXt m4 openssl-devel \
        pandoc pango pango-devel python-devel python3-pip readline-static readline-devel which xz udunits2 udunits2-devel unzip zip && \
    yum reinstall -y libpng libpng-devel zlib zlib-devel && \
    unzip -o mro-3.5.1.zip && rm mro-3.5.1.zip && source /var/task/setup.sh && \
    cp /usr/lib64/libgmp.so.10 lib64/libgmp.so.3 && ldconfig
RUN curl -LO https://github.com/Kitware/CMake/releases/download/v3.18.5/cmake-3.18.5-Linux-x86_64.tar.gz && \
    tar -xf cmake-3.18.5-Linux-x86_64.tar.gz && \
    git clone https://github.com/libgit2/libgit2.git && \
    cd libgit2 && git checkout v1.1.0 && \
    mkdir build && cd build && \
    ../../cmake-3.18.5-Linux-x86_64/bin/cmake .. && \
    ../../cmake-3.18.5-Linux-x86_64/bin/cmake --build . && \
    make install && cd /var/task && \
    curl -LO https://real-currents.s3-us-west-1.amazonaws.com/r/adam-installer-4.4.0-Linux-x86_64.sh && \
    chmod +x adam-installer-4.4.0-Linux-x86_64.sh && \
    bash adam-installer-4.4.0-Linux-x86_64.sh -b -p /var/task/adam && \
    echo -e '\n# Anaconda Adam\nexport PATH=/var/task/adam/bin:$PATH' >> ~/.bashrc && \
    echo -e 'export LD_LIBRARY_PATH="/var/task/lib64:/var/task/lib"' >> ~/.bashrc && \
    conda create -y -n r-reticulate python=3.5.4 && \
    cd /var/task/adam/envs/r-reticulate/lib && mv libz.so.1 libz.so.1.old && ln -s /var/task/adam/lib/libz.so.1 libz.so.1 && \
    source activate r-reticulate && cd /tmp && \
    curl -L https://real-currents.s3-us-west-1.amazonaws.com/r/gdal-2.4.4.tar.gz | tar zxf - && \
    cd gdal-2.4.4/ && \
    ./configure --prefix=/usr/local && \
    make -j4 && \
    make install && \
    cp -r /usr/local/lib/* /var/task/lib64/
