FROM ghcr.io/luomus/base-r-image@sha256:bfc65b835b503a235459716a9eb8afefb2bec94effdb19e69573885b898b00e8

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
