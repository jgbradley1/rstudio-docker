FROM rstudio/r-base:3.5-bionic

COPY rstudio-server-1.2.5019-amd64.deb .Rprofile rstudio_recommended_deb_packages.txt rstudio_recommended_packages.txt rserver.conf supervisord.conf /

RUN apt-get update -qqy && apt upgrade -y \
    && apt-get install -y $(grep -vE "^\s*#" rstudio_recommended_deb_packages.txt  | tr "\n" " ") \
    && mv supervisord.conf /etc/supervisor/conf.d/ \
    && mkdir -p /etc/rstudio && mv rserver.conf /etc/rstudio/ \
    && gdebi -n rstudio-server-1.2.5019-amd64.deb \
    && rm ./rstudio-server-1.2.5019-amd64.deb

# update where R expects to find Java files
RUN R CMD javareconf
RUN useradd -mg sudo rstudio \
    && echo rstudio:rstudio | chpasswd \
    && mv .Rprofile ~/ \
    && R -e "pkgs <- readLines('rstudio_recommended_packages.txt'); install.packages(pkgs);"

RUN mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord"]