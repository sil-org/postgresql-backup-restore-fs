FROM alpine:3.20

RUN apk update \
 && apk add --no-cache \
            bash \
            postgresql16-client

# AWS RDS CA bundle covering all regions, for verifying the DB server certificate.
# Used only when PGSSLMODE=verify-full and PGSSLROOTCERT=/etc/ssl/rds-ca-bundle.pem are set.
ADD https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem /etc/ssl/rds-ca-bundle.pem

COPY application/ /data/
WORKDIR /data

CMD ["./entrypoint.sh"]
