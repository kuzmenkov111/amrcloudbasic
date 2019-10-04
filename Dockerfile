FROM ubuntu:bionic

RUN useradd docker \
	&& mkdir /home/docker \
	&& mkdir /home/docker/app \
	&& mkdir /home/docker/data \
	&& mkdir /home/docker/cashe \
	&& mkdir /home/docker/deleted \
	&& chown -R docker:docker /home/docker \
	&& addgroup docker staff
	
RUN apt update \
	&& apt install -y locales \	
	&& echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

## Install some useful tools and dependencies for MRO
RUN apt update \
	&& apt install -y --no-install-recommends \
	apt-utils \
	ca-certificates \
	curl \
        wget \
	&& rm -rf /var/lib/apt/lists/*

# system libraries of general use
RUN apt update && apt install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.0.0 \
    libxml2-dev \
    gdebi \
    libssl-dev \
    systemd \
    zip \
    unzip

# system library dependency for the euler app
RUN apt update && apt install -y \
    libmpfr-dev \
    gfortran \
    aptitude \
    libgdal-dev \
    libproj-dev \
    g++ \
    libicu-dev \
    libpcre3-dev\
    libbz2-dev \
    liblzma-dev \
    libnlopt-dev \
    build-essential \
    uchardet libuchardet-dev \
    task-spooler \
    cmake \
    cron \
    git-core
    
WORKDIR /home/docker
RUN sudo wget https://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb
RUN sudo dpkg -i libpng12-0_1.2.54-1ubuntu1_amd64.deb 
# Download, valiate, and unpack and install Micrisift R open
RUN wget https://www.dropbox.com/s/uz4e4d0frk21cvn/microsoft-r-open-3.5.1.tar.gz?dl=1 -O microsoft-r-open-3.5.1.tar.gz \
&& echo "9791AAFB94844544930A1D896F2BF1404205DBF2EC059C51AE75EBB3A31B3792 microsoft-r-open-3.5.1.tar.gz" > checksum.txt \
	&& sha256sum -c --strict checksum.txt \
	&& tar -xf microsoft-r-open-3.5.1.tar.gz \
	&& cd /home/docker/microsoft-r-open \
	&& ./install.sh -a -u \
	&& ls logs && cat logs/*


# Clean up
WORKDIR /home/docker
RUN rm microsoft-r-open-3.5.1.tar.gz \
	&& rm checksum.txt \
&& rm -r microsoft-r-open


RUN apt install -y software-properties-common
RUN sudo add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable \
&& apt update \
&& apt install -y libudunits2-dev libgdal-dev libgeos-dev \
&& apt install -y openjdk-11-jdk \
&& java -version

RUN sudo wget https://www.dropbox.com/s/sgdwyp7kve44gtp/mailsend-go_linux_64-bit.deb?dl=1 -O mailsend-go_linux_64-bit.deb \
&& dpkg -i mailsend-go_linux_64-bit.deb \
&& rm mailsend-go_linux_64-bit.deb

#RUN sudo apt-add-repository -y ppa:webupd8team/java \
#&& apt update && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections && apt-get install -y oracle-java8-installer \
#&& R -e "Sys.setenv(JAVA_HOME = '/usr/lib/jvm/java-8-oracle/jre')"
#RUN sudo java -version

# basic shiny functionality
RUN sudo R -e "install.packages('rmarkdown', repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('shiny'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('shinyjs'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('shinythemes'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('dplyr'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('data.table'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('pool'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('bcrypt'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('binom'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('RPostgres'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('DBI'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('cronR'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('commonmark'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('httr', 'processx', 'tidyr', 'ggplot2'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('remotes', 'blastula'), repos='https://cran.amrcloud.net/')" 
