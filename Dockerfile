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
    cp -a -L /lib/x86_64-linux-gnu/libc.so.* "$LIBDIR"/ && \
    cp -a -L /usr/local/bin/redis-server "$LIBDIR"/ && \
    cp -a -L /usr/local/bin/redis-sentinel "$LIBDIR"/ 


FROM gcr.io/distroless-dev/base-debian10

ENV LIBDIR /data

COPY --from=base /usr/lib/redis/modules /data

VOLUME /data
WORKDIR /data

ENTRYPOINT [ "/data/redis-server" ]
