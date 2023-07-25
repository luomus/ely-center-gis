FROM ghcr.io/luomus/base-r-image@sha256:047e13660472b4e82a2de18b3aca9900edd0ac67ddcf729e71a6c53a29c6c09b

ENV STATUS_DIR="var/status"
ENV LOG_DIR="var/logs"

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
  && permissions.sh

