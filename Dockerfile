# Debian 11 is recommended.
FROM debian:11-slim

RUN apt update && apt install -y procps tini libjemalloc2

RUN apt install -y libgomp1
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

# Add extra jars.
ENV SPARK_EXTRA_JARS_DIR=/opt/spark/jars/
ENV SPARK_EXTRA_CLASSPATH='/opt/spark/jars/*'
RUN mkdir -p "${SPARK_EXTRA_JARS_DIR}"

# Uncomment below and replace EXTRA_JAR_NAME with the jar file name.
# COPY "EXTRA_JAR_NAME" "${SPARK_EXTRA_JARS_DIR}"

# Required
RUN apt update && apt install -y python3 python3-pip

# Required
RUN pip3 install --no-cache-dir \
      numpy \
      pandas \
      scikit-learn \
      matplotlib \
      seaborn \
      requests \
      pyarrow \
      fastparquet \
      cython \
      nltk \
      scipy \
      sympy \
      sqlalchemy

# (Optional) Add extra Python modules or scripts
ENV PYTHONPATH=/opt/python/packages
RUN mkdir -p "${PYTHONPATH}"
COPY test_util.py "${PYTHONPATH}"

# (Optional) Install R and R libraries
RUN apt update \
  && apt install -y gnupg \
  && apt-key adv --no-tty \
      --keyserver "hkp://keyserver.ubuntu.com:80" \
      --recv-keys E19F5F87128899B192B1A2C2AD5F960A256A04AF \
  && echo "deb http://cloud.r-project.org/bin/linux/debian bullseye-cran40/" \
      >/etc/apt/sources.list.d/cran-r.list \
  && apt update \
  && apt install -y \
      libopenblas-base \
      libssl-dev \
      r-base \
      r-base-dev \
      r-recommended \
      r-cran-blob

# Set R environment variables
ENV R_HOME=/usr/lib/R

# Create the 'spark' group/user.
# The GID and UID must be 1099. Home directory is required.
RUN groupadd -g 1099 spark
RUN useradd -u 1099 -g 1099 -d /home/spark -m spark
USER spark
