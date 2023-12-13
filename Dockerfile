FROM ghcr.io/luomus/base-r-image@sha256:b665e5c35cdc133e5d9f8e9f2b733107c7e784512f390802caaa1f7c9e1a0432

ENV RENV_PATHS_LIBRARY renv/library

COPY renv.lock renv.lock

RUN R -e "install.packages('renv')" \
 && R -e "renv::restore()"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY ely-centers.rds /home/user/ely-centers.rds
COPY ely.R /home/user/ely.R
COPY setup.R /home/user/setup.R
COPY db-setup.R /home/user/db-setup.R
COPY query.R /home/user/query.R
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
