FROM debian:wheezy
ADD . /opt
RUN apt-get -y update && apt-get -y install gawk
CMD ["bash", "/opt/cpuInfo.bash"]

