#FROM docker.io/realcurrents/amzn-mro-3.5.1:base as base
#
#ENV LD_LIBRARY_PATH /var/task/lib64:/var/task/lib:/usr/local/lib64:/usr/local/lib:/usr/lib64
#ENV PATH /var/task/adam/bin:/var/task/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#ENV REXEC R
#ENV LC_ALL C.UTF-8
#ENV LANG C.UTF-8
#
#RUN yum install -y wget
#
#RUN cd /var/task && source /var/task/setup.sh && ldconfig && \
#    export RPROFILE="$(echo $(/var/task/bin/R -f /var/task/setup.R  | grep '/Rprofile') | grep -o '[A-Z|a-z|\/][A-Z|a-z|0-9|\:|\/|\.|\_]*')" && \
#    echo $(for rp in $RPROFILE; do echo 'options(repos = list(MRAN = "https://mran.microsoft.com/snapshot/2018-08-01", CRAN = "http://cran.rstudio.com/"))' >> $rp; done;) && \
#    Rscript -e 'remove.packages(c("curl","httr"));' && \
#    echo -e '\nexport CURL_CA_BUNDLE=/var/task/lib64/R/lib/microsoft-r-cacert.pem' >> ~/.bashrc && \
#    echo -e '\nexport LC_ALL=C.UTF-8' >> ~/.bashrc && \
#    echo -e '\nexport LANG=C.UTF-8' >> ~/.bashrc && \
#    /var/task/bin/Rscript -e 'install.packages(c("curl", "httr", "Rcpp")); Sys.setenv(CURL_CA_BUNDLE="/var/task/lib64/R/lib/microsoft-r-cacert.pem")'
#
#RUN /var/task/bin/Rscript -e 'install.packages(c("cli", "glue", "devtools", "dplyr", "magrittr", "rlang", "stringr", "tidyverse", "usethis", "utf8"));'
#
#RUN /var/task/bin/Rscript -e 'install.packages(c("jsonlite", "magick", "openxlsx", "Rcpp", "RcppRedis", "remoter", "remotes", "stringi", "stringr"));'
#
#RUN /var/task/bin/Rscript -e 'devtools::install_github("rspatial/raster@e2664474b3262692c95856157a76fc0a9fa1af63", upgrade = "never");'
#
#RUN /var/task/bin/Rscript -e 'devtools::install_version("raster", version = "3.4-13", upgrade = "never");'
#
#RUN /var/task/bin/Rscript -e 'setwd("/tmp"); system("wget https://cran.r-project.org/src/contrib/Archive/terra/terra_0.5-8.tar.gz"); install.packages("terra_0.5-8.tar.gz");'
#
#RUN /var/task/bin/Rscript -e 'install.packages(c("geojsonsf", "geoviz", "rgdal", "rgeos", "sf", "sp", "slippymath"));'

FROM docker.io/realcurrents/amzn-mro-3.5.1:geobase as base

RUN yum install -y libffi-devel

RUN /var/task/bin/Rscript -e 'remotes::install_cran("azuremlsdk"); azuremlsdk::install_azureml(envnam = "r-reticulate", conda_python_version = "3.5.3", restart_session = TRUE, remove_existing_env = FALSE); reticulate::use_python(python = "/var/task/adam/envs/r-reticulate/bin/python", required = TRUE); reticulate::use_condaenv(condaenv = "r-reticulate"); system("/var/task/adam/envs/r-reticulate/bin/python -m pip install --upgrade pip"); system("/var/task/adam/envs/r-reticulate/bin/python -m pip install --upgrade pip"); system("/var/task/adam/envs/r-reticulate/bin/python -m pip install azureml"); system("/var/task/adam/envs/r-reticulate/bin/python -m pip install azure-ml-api-sdk"); system("/var/task/adam/envs/r-reticulate/bin/python -m pip install azureml.core"); system("/var/task/adam/envs/r-reticulate/bin/python -m pip install --upgrade azureml-sdk"); system("/var/task/adam/envs/r-reticulate/bin/python -m pip install --upgrade azureml-sdk[notebooks,contrib]"); save.image();'  &&\
    echo $(for rp in $RPROFILE; do echo 'load("/var/task/.RData")' >> $rp; done;) && \
    echo $(for rp in $RPROFILE; do echo 'reticulate::use_python(python = "/var/task/adam/envs/r-reticulate/bin/python", required = TRUE)' >> $rp; done;) && \
    echo $(for rp in $RPROFILE; do echo 'reticulate::use_condaenv(condaenv = "r-reticulate")' >> $rp; done;)

FROM docker.io/realcurrents/amzn-mro-3.5.1:origin as runtime
COPY --from=base /var/task /var/task

ENV LD_LIBRARY_PATH /var/task/lib64:/var/task/lib:/usr/local/lib64:/usr/local/lib:/usr/lib64
ENV PATH /var/task/adam/bin:/var/task/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV REXEC Rscript

RUN yum -y update && \
    yum groupinstall -y "Development Tools" && \
    yum install -y armadillo cmake dbus dbus-libs fontconfig gdal geos jq proj proj-nad proj-epsg postgresql v8 \
        libcairo libcurl libcurl-devel libgomp libSM libjpeg-turbo-devel libpng12 libXt m4 openssl-devel \
        pandoc pango python-devel python3-pip readline-static tar which xz udunits2 udunits2-devel unzip && \
    yum reinstall -y libpng libpng-devel zlib zlib-devel && \
    yum clean all

WORKDIR /data

ENTRYPOINT [ "bash", "-c", "/var/task/bin/$REXEC $0 $1 $2 $3 $4 $5 $6 $7 $8 $9" ]
CMD [ "", "", "", "", "", "", "", "", "", "" ]
