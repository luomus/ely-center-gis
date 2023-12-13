FROM ghcr.io/luomus/base-r-image@sha256:b665e5c35cdc133e5d9f8e9f2b733107c7e784512f390802caaa1f7c9e1a0432

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

