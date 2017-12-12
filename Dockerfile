# wazo docker installation
FROM debian:jessie
MAINTAINER C.U.tech "cody@c-u-tech.com" (XiVO version originally by Sylvain Boily "sboily@proformatique.com")

# Set ENV
ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV HOME /root
ENV init /lib/systemd/systemd

# Add necessary files
ADD http://mirror.wazo.community/fai/xivo-migration/wazo_install.sh /root/wazo_install.sh
ADD https://raw.githubusercontent.com/wazo-pbx/wazo-service/master/bin/wazo-service /root/wazo-service

# Chmod
RUN chmod +x /root/wazo_install.sh \
    && chmod +x /root/wazo-service

# Update repo (Added Nano as well as vim)
RUN apt-get -qq update \
    && apt-get -qq -y install \
                      apt-utils \
                      locales \
                      wget \
                      vim \
                      nano \
                      net-tools \
                      rsyslog \
                      udev \
                      iptables \
                      kmod

# Update locales
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
RUN dpkg-reconfigure locales

# Install WAZO
RUN /root/wazo_install.sh -d

# Fix
RUN rm /usr/sbin/policy-rc.d
RUN touch /etc/network/interfaces

# Clean
RUN apt-get clean
RUN rm /root/wazo_install.sh

# Fix for systemd on docker
RUN cd /lib/systemd/system/sysinit.target.wants/; ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1 \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*; \
    rm -f /lib/systemd/system/plymouth*; \
    rm -f /lib/systemd/system/systemd-update-utmp*;
RUN systemctl set-default multi-user.target

# WAZO-Incredible PBX inatall/docker-compose.yml handles volumes VOLUME [ "/sys/fs/cgroup" ]
EXPOSE 80 443 5003 9486

ENTRYPOINT ["/lib/systemd/systemd"]
CMD ["/root/wazo-service", "loop"]-+  
