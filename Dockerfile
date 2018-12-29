FROM debian:wheezy
ADD . /opt
CMD ["bash", "./cpuInfo.bash"]

