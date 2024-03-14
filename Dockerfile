FROM ghcr.io/luomus/base-r-image@sha256:b274fdd5ea06de31652330f805ea75e4ecdfb054399a2da812088fde11e3e309

ENV FINBIF_USER_AGENT=https://github.com/luomus/ely-center-gis
ENV STATUS_DIR="var/status"
ENV LOG_DIR="var/logs"

COPY renv.lock /home/user/renv.lock

RUN R -s -e "renv::restore()"

COPY ely-centers.rds /home/user/ely-centers.rds
COPY api.R /home/user/api.R
COPY ely.R /home/user/ely.R
COPY setup.R /home/user/setup.R
COPY db-setup.R /home/user/db-setup.R
COPY query.R /home/user/query.R
COPY transform-footprint.R /home/user/transform-footprint.R
COPY ely-subsets.R /home/user/ely-subsets.R
COPY ely-compute.R /home/user/ely-compute.R
COPY favicon.ico /home/user/favicon.ico

RUN permissions.sh
