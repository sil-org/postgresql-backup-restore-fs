FROM alpine:3.15

RUN apk update \
 && apk add --no-cache \
            bash \
            postgresql12-client

COPY application/ /data/
WORKDIR /data

CMD ["./entrypoint.sh"]
