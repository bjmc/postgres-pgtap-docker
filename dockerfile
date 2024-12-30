# Start with the official PostgreSQL image
FROM postgres:17

# Install dependencies and pgTap
RUN apt-get update && apt-get install -y \
    postgresql-server-dev-17 \
    postgresql-17 \
    make \
    gcc \
    libcpan-distnameinfo-perl \
    git \
    perl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure cpan to be non-interactive and install cpanminus
RUN echo "yes" | cpan App::cpanminus

# Install the TAP::Parser::SourceHandler::pgTAP Perl module
RUN cpanm TAP::Parser::SourceHandler::pgTAP

# Clone, build, and install pgTap
RUN git clone https://github.com/theory/pgtap.git /usr/local/src/pgtap \
    && cd /usr/local/src/pgtap \
    && make PG_CONFIG=/usr/lib/postgresql/17/bin/pg_config \
    && make install
# enable the extension
RUN echo "CREATE EXTENSION pgtap;" > /docker-entrypoint-initdb.d/01_pgtap.sql

# Clean up unnecessary files
RUN rm -rf /usr/local/src/pgtap
