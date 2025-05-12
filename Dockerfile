FROM rockylinux:8

ARG TARGET_FOLDER=/opt/nerve
ENV SODIUM_INSTALL=system

# Install all dependencies in a single RUN command to reduce layers
RUN dnf install -y epel-release dnf-plugins-core && \
    dnf config-manager --set-enabled powertools && \
    dnf update -y && \
    dnf install -y \
        gcc \
        make \
        redis \
        python3 \
        python3-pip \
        python3-devel \
        wget \
        nmap \
        findutils \
        libffi-devel \
        libsodium-devel \
        libjpeg-turbo-devel \
        zlib-devel \
        freetype-devel \
        lcms2-devel \
        libwebp-devel \
        openjpeg2-devel \
        openssl-devel \
        postgresql-devel && \
    # Pre-install problematic Python packages
    pip3 install --upgrade pip && \
    pip3 install psycopg2-binary==2.8.5 && \
    pip3 install --only-binary=:all: PyNaCl && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Create application directory
RUN mkdir -p $TARGET_FOLDER

# Copy application files (grouped by similar items)
COPY config.py main.py requirements.txt start.sh version.py $TARGET_FOLDER/
COPY bin/ $TARGET_FOLDER/bin/
COPY core/ $TARGET_FOLDER/core/
COPY db/ $TARGET_FOLDER/db/
COPY install/ $TARGET_FOLDER/install/
COPY logs/ $TARGET_FOLDER/logs/
COPY reports/ $TARGET_FOLDER/reports/
COPY rules/ $TARGET_FOLDER/rules/
COPY static/ $TARGET_FOLDER/static/
COPY templates/ $TARGET_FOLDER/templates/
COPY views/ $TARGET_FOLDER/views/
COPY views_api/ $TARGET_FOLDER/views_api/

# Set up working directory and install requirements
WORKDIR $TARGET_FOLDER/
RUN pip3 install --user --prefer-binary -r requirements.txt && \
    chmod 755 main.py start.sh

# Set the entrypoint and expose the port
ENTRYPOINT ["/opt/nerve/start.sh"]
EXPOSE 8080/tcp

