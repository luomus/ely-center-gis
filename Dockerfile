FROM rstudio/plumber:v1.2.0

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      gdal-bin \
      libgdal-dev \
      libgeos-dev \
      libpq-dev \
      libproj-dev \
      libudunits2-dev \
      libz-dev \
 && apt-get autoremove -y \
 && apt-get autoclean -y \
 && rm -rf /var/lib/apt/lists/*

ENV RENV_PATHS_LIBRARY renv/library

COPY renv.lock renv.lock

RUN R -e "install.packages('renv')" \
 && R -e "renv::restore()"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY ely.R /home/user/ely.R
COPY setup.R /home/user/setup.R
COPY db-setup.R /home/user/db-setup.R
COPY transform-footprint.R /home/user/transform-footprint.R
COPY ely-subsets.R /home/user/ely-subsets.R
COPY ely-compute.R /home/user/ely-compute.R
COPY init.R /home/user/init.R

ENV  HOME /home/user
ENV  OPENBLAS_NUM_THREADS 1

WORKDIR /home/user

RUN  mkdir -p /home/user/var \
  && chgrp -R 0 /home/user \
  && chmod -R g=u /home/user /etc/passwd

USER 1000

EXPOSE 8000

ENTRYPOINT ["entrypoint.sh"]

CMD ["Rscript", "--vanilla", "init.R"]
