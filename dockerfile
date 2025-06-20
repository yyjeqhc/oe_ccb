FROM openeuler/openeuler:24.03-lts-sp1
COPY oerv.repo /etc/yum.repos.d/oerv.repo
RUN dnf update -y && \
    dnf install -y vim ccb wget docker patch && \
    dnf clean all
CMD ["/bin/bash"]
