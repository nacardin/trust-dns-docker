FROM rust:1.39 as rust-builder
RUN cd /tmp && git clone https://github.com/bluejekyll/trust-dns.git --depth 1

RUN apt-get update && apt-get install crossbuild-essential-armhf -y --no-install-recommends

RUN rustup target add armv7-unknown-linux-gnueabihf

COPY cargo.config /tmp/trust-dns/bin/.cargo/config

RUN cd /tmp/trust-dns/bin && \
    cargo build --target armv7-unknown-linux-gnueabihf --features dns-over-tls,dns-over-rustls --release

ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-armhf /tmp/tini
RUN chmod +x /tmp/tini

FROM arm32v7/debian:buster
COPY --from=rust-builder /tmp/trust-dns/target/armv7-unknown-linux-gnueabihf/release/named /usr/local/bin/named
COPY --from=rust-builder /tmp/trust-dns/tests/test-data/named_test_configs/default /var/named/default
COPY --from=rust-builder /tmp/tini /tini

EXPOSE 53
ENTRYPOINT ["/tini", "--"]
CMD ["/usr/local/bin/named"]
