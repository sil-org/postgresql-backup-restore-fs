FROM alpine:3.20

RUN apk update \
 && apk add --no-cache \
            bash \
            postgresql16-client

COPY application/ /data/
WORKDIR /data

CMD ["./entrypoint.sh"]
