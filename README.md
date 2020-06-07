Microsoft R Open
================

Docker Amazon Linux with Microsoft R Open 3.5.1

Tags:
  - `latest` - (mkl)
  - `mkl` - Full distribution of all MRO libraries, including Intel MKL and ability to install new packages within R
  - `packages` - Build of MRO with basic R libraries and ability to install new packages within R
  - `minimum` - Build of MRO with basic R libraries (packages are static)


    docker run -it --mount type=bind,source="$(pwd)",destination=/data --privileged --rm docker.io/realcurrents/amzn-mro-3.5.1:latest

    docker run -it --mount type=bind,source="$(pwd)",destination=/data --privileged --rm -e "REXEC=Rscript" docker.io/realcurrents/amzn-mro-3.5.1:latest "/data/script.R" "ARG1" "ARG2" "ARG3"

In order to alias "R" and/or "Rscript" within the bash shell you can create the following script in `/usr/local/bin` (or any other writable directory in your `$PATH`):

    #!/usr/bin/env bash
    # r-docker.sh or r-podman.sh

    docker run -it ---mount type=bind,source="$(pwd)",destination=/data --privileged --rm -e "REXEC=`basename $0`" docker.io/realcurrents/amzn-mro-3.5.1:latest $1 $2 $3 $4 $5 $6 $7 $8 $9
    # On Fedora/RedHat:
    # podman run -it --mount type=bind,source=.,destination=/data --privileged --rm -e "REXEC=`basename $0`" docker.io/realcurrents/amzn-mro-3.5.1:latest $1 $2 $3 $4 $5 $6 $7 $8 $9

... and then create symlinks:

    chmod +x /usr/local/bin/r-docker.sh
    ln -s /usr/local/bin/r-docker.sh /usr/local/bin/R
    ln -s /usr/local/bin/r-docker.sh /usr/local/bin/Rscript

This allows to run an interactive R session within a container:

    R

    R version 3.5.1 (2018-07-02) -- "Feather Spray"
    Copyright (C) 2018 The R Foundation for Statistical Computing
    Platform: x86_64-pc-linux-gnu (64-bit)
    
    R is free software and comes with ABSOLUTELY NO WARRANTY.
    You are welcome to redistribute it under certain conditions.
    Type 'license()' or 'licence()' for distribution details.
    
    R is a collaborative project with many contributors.
    Type 'contributors()' for more information and
    'citation()' on how to cite R or R packages in publications.
    
    Type 'demo()' for some demos, 'help()' for on-line help, or
    'help.start()' for an HTML browser interface to help.
    Type 'q()' to quit R.
    
    Microsoft R Open 3.5.1
    The enhanced R distribution from Microsoft
    Microsoft packages Copyright (C) 2018 Microsoft Corporation
    
    Using the Intel MKL for parallel mathematical computing (using 4 cores).
    
    Default CRAN mirror snapshot taken on 2018-08-01.
    See: https://mran.microsoft.com/.
    
    > 
