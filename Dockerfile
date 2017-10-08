FROM alpine:3.5

MAINTAINER Huang Rui <vowstar@gmail.com>, Turtle <turtled@emqtt.io>

ENV EMQX_VERSION=v2.4

COPY ./start.sh /start.sh

RUN set -ex \
    # add build deps, remove after build
    && apk --no-cache add --virtual .build-deps \
        build-base \
        # gcc \
        # make \
        bsd-compat-headers \
        perl \
        erlang \
        erlang-public-key \
        erlang-syntax-tools \
        erlang-erl-docgen \
        erlang-gs \
        erlang-observer \
        erlang-ssh \
        #erlang-ose \
        erlang-cosfiletransfer \
        erlang-runtime-tools \
        erlang-os-mon \
        erlang-tools \
        erlang-cosproperty \
        erlang-common-test \
        erlang-dialyzer \
        erlang-edoc \
        erlang-otp-mibs \
        erlang-crypto \
        erlang-costransaction \
        erlang-odbc \
        erlang-inets \
        erlang-asn1 \
        erlang-snmp \
        erlang-erts \
        erlang-et \
        erlang-cosnotification \
        erlang-xmerl \
        erlang-typer \
        erlang-coseventdomain \
        erlang-stdlib \
        erlang-diameter \
        erlang-hipe \
        erlang-ic \
        erlang-eunit \
        #erlang-webtool \
        erlang-mnesia \
        erlang-erl-interface \
        #erlang-test-server \
        erlang-sasl \
        erlang-jinterface \
        erlang-kernel \
        erlang-orber \
        erlang-costime \
        erlang-percept \
        erlang-dev \
        erlang-eldap \
        erlang-reltool \
        erlang-debugger \
        erlang-ssl \
        erlang-megaco \
        erlang-parsetools \
        erlang-cosevent \
        erlang-compiler \
    # add fetch deps, remove after build
    && apk add --no-cache --virtual .fetch-deps \
        git \
        wget \
    # add run deps, never remove
    && apk add --no-cache --virtual .run-deps \
        ncurses-terminfo-base \
        ncurses-terminfo \
        ncurses-libs \
        readline \
    # add latest rebar
    && wget https://github.com/rebar/rebar/wiki/rebar -O /usr/bin/rebar \
    && chmod +x /usr/bin/rebar \
    && git clone -b ${EMQX_VERSION} https://github.com/emqtt/emq-relx.git /emqx-rel \
    && cd /emqx-rel \
    && make \
    && mkdir -p /opt && mv /emqx-rel/_rel/emqx /opt/emqx \
    && cd / && rm -rf /emqx-rel \
    && mv /start.sh /opt/emqx/start.sh \
    && chmod +x /opt/emqx/start.sh \
    && ln -s /opt/emqx/bin/* /usr/local/bin/ \
    # remove rebar
    && rm -rf /usr/bin/rebar \
    && rm -rf /root/.ssh/ \
    # removing fetch deps and build deps
    && apk --purge del .build-deps .fetch-deps \
    && rm -rf /var/cache/apk/*

WORKDIR /opt/emqx

# start emqx and initial environments
CMD ["/opt/emqx/start.sh"]

VOLUME ["/opt/emqx/log", "/opt/emqx/data", "/opt/emqx/lib", "/opt/emqx/etc"]

# emqx will occupy these port:
# - 1883 port for MQTT
# - 8883 port for MQTT(SSL)
# - 8083 for WebSocket/HTTP
# - 8084 for WSS/HTTPS
# - 18083 for dashboard
# - 4369 for port mapping
# - 5369 for gen_rpc port mapping
# - 6369 for distributed node
EXPOSE 1883 8883 8083 8084 18083 4369 5369 6369
