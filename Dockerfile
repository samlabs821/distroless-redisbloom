FROM redislabsmodules/rmbuilder:latest as builder

# Build the source
ADD . /
WORKDIR /
RUN set -ex;\
    make clean; \
    make all -j 4; \
    make test;

# Package the runner
FROM redis:latest as base
ENV LIBDIR /usr/lib/redis/modules
WORKDIR /data
RUN set -ex;\
    mkdir -p "$LIBDIR";
COPY --from=builder /redisbloom.so "$LIBDIR"

RUN cp -a -L /lib/x86_64-linux-gnu/libm.so.* "$LIBDIR"/ && \
    cp -a -L /lib/x86_64-linux-gnu/libdl.so.* "$LIBDIR"/ && \
    cp -a -L /lib/x86_64-linux-gnu/libpthread.so.* "$LIBDIR"/ && \
    cp -a -L /lib/x86_64-linux-gnu/libc.so.* "$LIBDIR"


# runtime image
FROM gcr.io/distroless-dev/base-debian10

ENV LIBDIR /lib/x86_64-linux-gnu/

COPY --from=base /usr/lib/redis/modules "$LIBDIR"
COPY --from=base /usr/local/bin/redis-server /bin

USER nonroot:nonroot

VOLUME /data
WORKDIR /data

COPY conf/redis.conf /etc/redis/redis.conf
COPY conf/redis_override.conf /etc/redis/redis_override.conf

CMD [ "redis-server", "/etc/redis/redis_override.conf", "--loadmodule", "/lib/x86_64-linux-gnu/redisbloom.so" ]
