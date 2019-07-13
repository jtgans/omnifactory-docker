FROM java:8

VOLUME /data

RUN addgroup --gid 1234 minecraft && \
    adduser \
        --disabled-password \
        --home=/data \
        --uid 1234 \
        --gid 1234 \
        --gecos "minecraft user" \
        minecraft && \
    chown minecraft:minecraft /data

WORKDIR /install
COPY --chown=root:root server/ /install/
COPY --chown=root:root start.sh /install/

USER minecraft:minecraft
EXPOSE 25565/tcp 25575/tcp

WORKDIR /data
CMD [ "-Xmx6144m", "-Xms256m", "-XX:PermSize=256m" ]
ENTRYPOINT [ "/install/start.sh" ]
