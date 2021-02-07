FROM docker.io/realcurrents/amzn-mro-3.5.1:base

ENV LD_LIBRARY_PATH /var/task/lib64:/usr/local/lib
ENV PATH /var/task/adam/bin:/var/task/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV REXEC R
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

RUN yum groupinstall -y "Development Tools" && \
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm && \
    yum -y install https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm && \
    yum -y update && \
    yum install -y armadillo armadillo-devel cmake libcurl-devel libgit2-devel less freeglut-devel gmp-devel gdal-devel geos-devel proj-devel proj-nad proj-epsg \
        ImageMagick-c++-devel libcairo libcurl libcurl-devel libjpeg-turbo-devel libpng12 libpng-devel libXt m4 openssl-devel \
        pandoc pango pango-devel python-devel python3-pip readline-static readline-devel which xz udunits2 udunits2-devel unzip zip && \
    yum reinstall -y libpng libpng-devel zlib zlib-devel && \
    cd /tmp && \
    curl -L https://real-currents.s3-us-west-1.amazonaws.com/r/gdal-2.4.4.tar.gz | tar zxf - && \
    cd gdal-2.4.4/ && \
    ./configure --prefix=/usr/local --without-python && \
    make -j4 && \
    make install && \
    cp -r /usr/local/lib/* /var/task/lib64/
RUN cd /var/task && curl -o mro-3.5.1.zip https://real-currents.s3-us-west-1.amazonaws.com/r/mro-3.5.1.zip && \
    unzip -o mro-3.5.1.zip && rm mro-3.5.1.zip && source /var/task/setup.sh && \
    cp /usr/lib64/libgmp.so.10 lib64/libgmp.so.3 && ldconfig && \
    curl -LO https://github.com/Kitware/CMake/releases/download/v3.18.5/cmake-3.18.5-Linux-x86_64.tar.gz && \
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
    export RPROFILE="$(echo $(/var/task/bin/R -f /var/task/setup.R  | grep '/Rprofile') | grep -o '[A-Z|a-z|\/][A-Z|a-z|0-9|\:|\/|\.|\_]*')" && \
    echo $(for rp in $RPROFILE; do echo 'options(repos = list(CRAN="http://cran.rstudio.com/"))' >> $rp; done;) && \
    Rscript -e 'remove.packages(c("curl","httr"));' && \
    echo -e '\nexport CURL_CA_BUNDLE=/var/task/lib64/R/lib/microsoft-r-cacert.pem' >> ~/.bashrc && \
    echo -e '\nexport LC_ALL=C.UTF-8' >> ~/.bashrc && \
    echo -e '\nexport LANG=C.UTF-8' >> ~/.bashrc && \
    echo -e '\n# Anaconda Adam\nexport PATH=/var/task/adam/bin:$PATH' >> ~/.bashrc && \
    Rscript -e 'install.packages(c("curl", "httr", "Rcpp")); Sys.setenv(CURL_CA_BUNDLE="/var/task/lib64/R/lib/microsoft-r-cacert.pem")' && \
    conda create -y -n r-reticulate python=3.5.4 && \
    cd /var/task/adam/envs/r-reticulate/lib && mv libz.so.1 libz.so.1.old && ln -s /lib64/libz.so.1
RUN cd /var/task && source /var/task/setup.sh && \
    curl -LO https://real-currents.s3-us-west-1.amazonaws.com/r/ghc-8.10.2-x86_64-fedora27-linux.tar.xz && \
    tar -xf ghc-8.10.2-x86_64-fedora27-linux.tar.xz && \
    cd ghc* && \
    ./configure --prefix=/var/task && \
    make install && \
    cd .. && \
    export LD_LIBRARY_PATH="$PWD/lib64;$PWD/lib" && \
    cd bin && \
    curl -LO https://real-currents.s3-us-west-1.amazonaws.com/r/cabal-install-1.24.0.0-x86_64-unknown-linux.tar.gz && \
    tar xf cabal* && \
    chmod +x cabal* &&\
    cabal sandbox init && \
    cabal update && \
    cabal install hsb2hs && \
    cd .cabal-sandbox/bin/  && \
    curl -LO https://real-currents.s3-us-west-1.amazonaws.com/r/pandoc.gz && \
    gunzip pandoc.gz && \
    chmod +x pandoc* && \
    cp ./* /usr/local/bin  && \
    cd ../../../ && \
    rm -rf lib
RUN cd /var/task && \
    Rscript -e 'install.packages(c("devtools", "jsonlite", "magrittr", "maptools", "openxlsx", "Rcpp", "RcppRedis")); devtools::install_github("rte-antares-rpackage/manipulateWidget", upgrade = FALSE); devtools::install_github("rstudio/shiny", upgrade = FALSE);' && \
    Rscript -e 'install.packages(c("remotes", "reticulate", "rmarkdown", "rgdal", "rgeos", "sf", "sp", "stringr", "tidyverse", "DT")); devtools::install_version("rgl", version = "0.100.19", dependencies = FALSE); devtools::install_github("tylermorganwall/rayimage@7a9a138e10e19119c88e960f9cfb191d1fdae002", upgrade = FALSE); devtools::install_github("tylermorganwall/terrainmeshr@e112055e47033508cc45c8246b8dc0a0e94920f7", upgrade = FALSE); devtools::install_github("tylermorganwall/rayshader@d0c9bd94be95c44eff6e7d8da5eadff070dc11db", upgrade = FALSE);' && \
    Rscript -e 'remotes::install_cran("azuremlsdk"); azuremlsdk::install_azureml(envnam = "r-reticulate", conda_python_version = "3.5.4", restart_session = TRUE, remove_existing_env = FALSE); reticulate::use_python(python = "/var/task/adam/envs/r-reticulate/bin/python", required = TRUE); reticulate::use_condaenv(condaenv = "r-reticulate"); system("/var/task/adam/envs/r-reticulate/bin/python -m pip install azureml"); system("/var/task/adam/envs/r-reticulate/bin/python -m pip install azure-ml-api-sdk"); system("/var/task/adam/envs/r-reticulate/bin/python -m pip install azureml.core"); system("/var/task/adam/envs/r-reticulate/bin/python -m pip install --upgrade azureml-sdk[notebooks,contrib]"); save.image();' && \
    Rscript -e 'devtools::install_version("blogdown", version = "0.20"); blogdown::install_hugo("0.64.0");' && \
    export RPROFILE="$(echo $(/var/task/bin/R -f /var/task/setup.R  | grep '/Rprofile') | grep -o '[A-Z|a-z|\/][A-Z|a-z|0-9|\:|\/|\.|\_]*')" && \
    echo $(for rp in $RPROFILE; do echo 'load("/var/task/.RData")' >> $rp; done;) && \
    echo $(for rp in $RPROFILE; do echo 'reticulate::use_python(python = "/var/task/adam/envs/r-reticulate/bin/python", required = TRUE)' >> $rp; done;) && \
    echo $(for rp in $RPROFILE; do echo 'reticulate::use_condaenv(condaenv = "r-reticulate")' >> $rp; done;)

WORKDIR /data
ENTRYPOINT [ "bash", "-c", "/var/task/bin/$REXEC $0 $1 $2 $3 $4 $5 $6 $7 $8 $9" ] 
CMD [ "", "", "", "", "", "", "", "", "", "" ]
