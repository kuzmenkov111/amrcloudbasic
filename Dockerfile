FROM debian:stretch

LABEL org.label-schema.license="GPL-2.0" \
      org.label-schema.vcs-url="https://github.com/rocker-org/rocker-versioned" \
      org.label-schema.vendor="Rocker Project" \
      maintainer="Carl Boettiger <cboettig@ropensci.org>"
RUN useradd -u 555 dockerapp\
    && mkdir /home/dockerapp\
    && mkdir /home/dockerapp/app \
    && mkdir /home/dockerapp/data \
    && mkdir /home/dockerapp/cashe \
    && mkdir /home/dockerapp/deleted \
    && chown -R dockerapp:dockerapp /home/dockerapp  \
    && addgroup dockerapp staff

ARG R_VERSION
ARG BUILD_DATE
ENV R_VERSION=${R_VERSION:-3.6.0} \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TERM=xterm

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash-completion \
    ca-certificates \
    file \
    fonts-texgyre \
    g++ \
    gfortran \
    gsfonts \
    libblas-dev \
    libbz2-1.0 \
    libcurl3 \
    libicu57 \
    libjpeg62-turbo \
    libopenblas-dev \
    libpangocairo-1.0-0 \
    libpcre3 \
    libpng16-16 \
    libreadline7 \
    libtiff5 \
    liblzma5 \
    locales \
    make \
    unzip \
    zip \
    zlib1g \
  && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen en_US.utf8 \
  && /usr/sbin/update-locale LANG=en_US.UTF-8 \
  && BUILDDEPS="curl \
    default-jdk \
    libbz2-dev \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libicu-dev \
    libpcre3-dev \
    libpng-dev \
    libreadline-dev \
    libtiff5-dev \
    liblzma-dev \
    libx11-dev \
    libxt-dev \
    perl \
    tcl8.6-dev \
    tk8.6-dev \
    texinfo \
    texlive-extra-utils \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-recommended \
    x11proto-core-dev \
    xauth \
    xfonts-base \
    xvfb \
    zlib1g-dev" \
  && apt-get install -y --no-install-recommends $BUILDDEPS \
  && cd tmp/ \
  ## Download source code
  && curl -O https://cran.r-project.org/src/base/R-3/R-${R_VERSION}.tar.gz \
  ## Extract source code
  && tar -xf R-${R_VERSION}.tar.gz \
  && cd R-${R_VERSION} \
  ## Set compiler flags
  && R_PAPERSIZE=letter \
    R_BATCHSAVE="--no-save --no-restore" \
    R_BROWSER=xdg-open \
    PAGER=/usr/bin/pager \
    PERL=/usr/bin/perl \
    R_UNZIPCMD=/usr/bin/unzip \
    R_ZIPCMD=/usr/bin/zip \
    R_PRINTCMD=/usr/bin/lpr \
    LIBnn=lib \
    AWK=/usr/bin/awk \
    CFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" \
    CXXFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" \
  ## Configure options
  ./configure --enable-R-shlib \
               --enable-memory-profiling \
               --with-readline \
               --with-blas \
               --with-tcltk \
               --disable-nls \
               --with-recommended-packages \
  ## Build and install
  && make \
  && make install \
  ## Add a default miniCRAN mirror
  && echo "options(repos = c(CRAN = 'https://cran.amrcloud.net/'), download.file.method = 'libcurl')" >> /usr/local/lib/R/etc/Rprofile.site \
  ## Add a library directory (for user-installed packages)
  && mkdir -p /usr/local/lib/R/site-library \
  && chown root:staff /usr/local/lib/R/site-library \
  && chmod g+wx /usr/local/lib/R/site-library \
  ## Fix library path
  && echo "R_LIBS_USER='/usr/local/lib/R/site-library'" >> /usr/local/lib/R/etc/Renviron \
  && echo "R_LIBS=\${R_LIBS-'/usr/local/lib/R/site-library:/usr/local/lib/R/library:/usr/lib/R/library'}" >> /usr/local/lib/R/etc/Renviron \
  
  ## Use littler installation scripts
  && Rscript -e "install.packages(c('littler', 'docopt'))" \
  && ln -s /usr/local/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
  && ln -s /usr/local/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
  && ln -s /usr/local/lib/R/site-library/littler/bin/r /usr/local/bin/r \
  ## Clean up from R source install
  && cd / \
  && rm -rf /tmp/* \
  && apt-get remove --purge -y $BUILDDEPS \
  && apt-get autoremove -y \
  && apt-get autoclean -y \
  && rm -rf /var/lib/apt/lists/*

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
    wget \
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
RUN sudo R -e "getOption('repos'); install.packages('rmarkdown')" \
&& R CMD javareconf -e \
&& R -e "Sys.setenv(JAVA_HOME = '/usr/lib/jvm/java-8-openjdk-amd64/jre'); install.packages(c('rJava'))" \
&& R -e "install.packages(c('shiny'))" \
&& R -e "install.packages(c('shinyjs'))" \
&& R -e "install.packages(c('shinythemes'))" \
&& R -e "install.packages(c('dplyr'))" \
&& R -e "install.packages(c('data.table'))" \
&& R -e "install.packages(c('pool'))" \
&& R -e "install.packages(c('bcrypt'))" \
&& R -e "install.packages(c('binom'))" \
&& R -e "install.packages(c('RPostgres'))" \
&& R -e "install.packages(c('DBI'))" \
&& R -e "install.packages(c('cronR'))" \
&& R -e "install.packages(c('commonmark'))" \
&& R -e "install.packages(c('httr', 'processx', 'tidyr', 'ggplot2'))" \
&& R -e "install.packages(c('remotes', 'blastula'))"
