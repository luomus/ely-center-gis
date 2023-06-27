FROM ghcr.io/luomus/base-r-image@sha256:7b02c5e1679ea46fa44e1d8ad8a56551fff2f90779e509676a378670e8e85517

COPY renv.lock /home/user/renv.lock
COPY ely-centers.rds /home/user/ely-centers.rds
COPY api.R /home/user/api.R
COPY ely.R /home/user/ely.R
COPY setup.R /home/user/setup.R
COPY db-setup.R /home/user/db-setup.R
COPY query.R /home/user/query.R
COPY transform-footprint.R /home/user/transform-footprint.R
COPY ely-subsets.R /home/user/ely-subsets.R
COPY ely-compute.R /home/user/ely-compute.R

RUN  R -e "renv::restore()" \
  && mkdir -p /home/user/var \
  && chgrp -R 0 /home/user \
  && chmod -R g=u /home/user /etc/passwd

ENV STATUS_DIR="var/status"
ENV LOG_DIR="var/logs"
