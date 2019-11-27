FROM rust:1.39 as rust-builder

RUN cd /tmp && git clone https://github.com/bluejekyll/trust-dns.git --depth 1

RUN cd /tmp/trust-dns/bin && \
    cargo build --features dns-over-tls,dns-over-rustls --release

ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tmp/tini
RUN chmod +x /tmp/tini

FROM debian:buster
COPY --from=rust-builder /tmp/trust-dns/target/release/named /usr/local/bin/named
COPY --from=rust-builder /tmp/trust-dns/tests/test-data/named_test_configs/default /var/named/default
COPY --from=rust-builder /tmp/tini /tini

EXPOSE 53
ENTRYPOINT ["/tini", "--"]
CMD ["/usr/local/bin/named"]
