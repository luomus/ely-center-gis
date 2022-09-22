FROM rocker/r-base:4.2.1

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      libpq-dev \
 && apt-get autoremove -y \
 && apt-get autoclean -y \
 && rm -rf /var/lib/apt/lists/*

ENV RENV_PATHS_LIBRARY renv/library
ENV RENV_CONFIG_REPOS_OVERRIDE https://packagemanager.rstudio.com/cran/__linux__/jammy/latest

COPY renv.lock renv.lock

RUN R -e "install.packages('renv')" \
 && R -e "renv::restore()"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY ely.R /home/user/ely.R
COPY setup.R /home/user/setup.R
COPY db-setup.R /home/user/db-setup.R
COPY transform-footprints.R /home/user/transform-footprints.R
COPY ely-subsets.R /home/user/ely-subsets.R
COPY ely-compute.R /home/user/ely-compute.R

ENV  HOME /home/user
ENV  OPENBLAS_NUM_THREADS 1

WORKDIR /home/user

RUN  mkdir -p /home/user
  && chgrp -R 0 /home/user \
  && chmod -R g=u /home/user /etc/passwd

USER 1000

ENTRYPOINT ["entrypoint.sh"]
