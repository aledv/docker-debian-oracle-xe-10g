FROM debian:wheezy

MAINTAINER 4l3DV <alessandro.divanni@gmail.com>

ADD assets /assets
RUN /assets/setup.sh

EXPOSE 22
EXPOSE 1521

CMD /usr/sbin/startup.sh && /usr/sbin/sshd -D
