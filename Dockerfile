FROM debian:testing

LABEL org.label-schema.license="GPL-2.0"
RUN useradd -u 555 dockerapp\
    && mkdir /home/dockerapp\
    && mkdir /home/dockerapp/app \
    && mkdir /home/dockerapp/data \
    && mkdir /home/dockerapp/cashe \
    && mkdir /home/dockerapp/deleted \
    && chown -R dockerapp:dockerapp /home/dockerapp  \
    && addgroup dockerapp staff


RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		ed \
		less \
		locales \
		vim-tiny \
		wget \
		ca-certificates \
		fonts-texgyre \
	&& rm -rf /var/lib/apt/lists/*
 

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

## Use Debian unstable via pinning -- new style via APT::Default-Release
RUN echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list \
        && echo 'APT::Default-Release "testing";' > /etc/apt/apt.conf.d/default

ENV R_BASE_VERSION 4.0.0

## Now install R and littler, and create a link for littler in /usr/local/bin
RUN apt-get update \
	&& apt-get install -t unstable -y --no-install-recommends \
		littler \
                r-cran-littler \
		r-base=${R_BASE_VERSION}-* \
		r-base-dev=${R_BASE_VERSION}-* \
		r-recommended=${R_BASE_VERSION}-* \
	&& ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
	&& install.r docopt \
	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
	&& rm -rf /var/lib/apt/lists/* \

  ## Add a default miniCRAN mirror
  && echo "options(repos = c(CRAN = 'https://cran.amrcloud.net/'), download.file.method = 'libcurl')" >> /etc/R/Rprofile.site
  
# system libraries of general use
RUN apt update && apt install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libssl-dev \
    libssh2-1-dev \
    libxml2-dev \
    gdebi \
    systemd \
    libmpfr-dev \
    aptitude \
    libgdal-dev \
    libproj-dev \
    libpcre3-dev\
    libbz2-dev \
    libnlopt-dev \
    build-essential \
    uchardet libuchardet-dev \
    task-spooler \
    cmake \
    cron \
    git-core \
    libcairo2-dev
RUN apt install -y software-properties-common
RUN sudo apt-get update \
&& apt-get install -y default-jre default-jdk \
&& apt install -y libudunits2-dev libgdal-dev libgeos-dev \
&& java -version
RUN sudo wget https://www.dropbox.com/s/sgdwyp7kve44gtp/mailsend-go_linux_64-bit.deb?dl=1 -O mailsend-go_linux_64-bit.deb \
&& dpkg -i mailsend-go_linux_64-bit.deb \
&& rm mailsend-go_linux_64-bit.deb


# basic shiny functionality
RUN sudo R -e "getOption('repos'); install.packages('rmarkdown', repos = 'https://cran.amrcloud.net/')" \
&& R CMD javareconf -e \
&& R -e "Sys.setenv(JAVA_HOME = '/usr/lib/jvm/java-8-openjdk-amd64/jre'); install.packages('rJava', repos = 'https://cran.amrcloud.net/')" \
&& R -e "install.packages('shiny', repos = 'https://cran.amrcloud.net/')" \
&& R -e "install.packages('shinyjs', repos = 'https://cran.amrcloud.net/')" \
&& R -e "install.packages('shinythemes', repos = 'https://cran.amrcloud.net/')" \
&& R -e "install.packages('dplyr', repos = 'https://cran.amrcloud.net/')" \
&& R -e "install.packages('data.table', repos = 'https://cran.amrcloud.net/')" \
&& R -e "install.packages('pool',repos = 'https://cran.amrcloud.net/')" \
&& R -e "install.packages('bcrypt', repos = 'https://cran.amrcloud.net/')" \
&& R -e "install.packages('binom', repos = 'https://cran.amrcloud.net/')" \
&& R -e "install.packages('RPostgres', repos = 'https://cran.amrcloud.net/')" \
&& R -e "install.packages('DBI', repos = 'https://cran.amrcloud.net/')" \
&& R -e "install.packages('cronR', repos = 'https://cran.amrcloud.net/')" \
&& R -e "install.packages('commonmark', repos = 'https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('httr', 'processx', 'tidyr', 'ggplot2'), repos = 'https://cran.amrcloud.net/')" \
&& R -e "install.packages('remotes')"
