FROM apache/superset:latest

USER root

RUN apt-get update && apt-get install -y \
    pkg-config \
    libmariadb-dev \
    default-libmysqlclient-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Instala drivers dentro del venv de Superset
# Forzamos psycopg2-binary porque tu stack usa el dialecto psycopg2
RUN . /app/.venv/bin/activate && \
    python -m pip install --no-cache-dir -U pip setuptools wheel && \
    python -m pip install --no-cache-dir \
      "psycopg2-binary==2.9.9" \
      "mysqlclient==2.2.4" \
      sqlalchemy-redshift \
      snowflake-sqlalchemy \
      snowflake-connector-python \
      sqlalchemy-bigquery \
      google-cloud-bigquery && \
    python - <<EOF
import sys
print("PY:", sys.executable)
import psycopg2
print("psycopg2:", psycopg2.__version__)
EOF

ENV ADMIN_USERNAME $ADMIN_USERNAME
ENV ADMIN_EMAIL $ADMIN_EMAIL
ENV ADMIN_PASSWORD $ADMIN_PASSWORD
ENV DATABASE $DATABASE

COPY /config/superset_init.sh ./superset_init.sh
RUN chmod +x ./superset_init.sh

COPY /config/superset_config.py /app/
ENV SUPERSET_CONFIG_PATH /app/superset_config.py
ENV SECRET_KEY $SECRET_KEY

USER superset

ENTRYPOINT [ "./superset_init.sh" ]
