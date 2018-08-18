#################################################################
# Dockerfile to build Zimbra Collaboration container images
#################################################################
FROM centos:6
MAINTAINER Thiago Vinhas <thiago@vinhas.net>

RUN yum -y install dnsmasq \
    git \
    net-tools \
    rsyslog \
    sudo \
    wget

RUN cd /opt/zimbra-install && wget https://files.zimbra.com/downloads/8.8.9_GA/zcs-8.8.9_GA_3019.RHEL6_64.20180809160254.tgz && \ 
    tar xfz zcs-* && rm -f /opt/zimbra-install/*.tar.gz

VOLUME ["/opt/zimbra"]

EXPOSE 22 25 465 587 110 143 993 995 80 443 8080 8443 7071

COPY opt /opt/

COPY etc /etc/

CMD ["/bin/bash", "/opt/start.sh", "-d"]
