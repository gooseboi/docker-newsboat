FROM debian:bookworm-20231009-slim as builder

# Install dependencies
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		git curl gcc g++ ca-certificates make libstfl-dev libsqlite3-dev \
		libcurl4 libcurl4-openssl-dev gettext \
		pkg-config libxml2-dev libjson-c-dev asciidoctor gawk \
		libssl-dev libcrypt-dev;

# Install rust
RUN set -eux; \
		curl --location --fail \
			"https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init" \
			--output /rustup-init; \
		chmod +x /rustup-init; \
		/rustup-init -y --no-modify-path --default-toolchain "1.70.0-x86_64-unknown-linux-gnu"; \
		rm /rustup-init;

# Add rustup to path, check that it works, and set profile to minimal
ENV PATH=${PATH}:/root/.cargo/bin
RUN set -eux; \
		rustup --version; \
		rustup set profile minimal;

# Clone project
RUN set -eux; \
	git clone https://github.com/newsboat/newsboat.git /newsboat;

# Build
WORKDIR /newsboat
RUN set -eux; \
	make

#########################################################################

FROM debian:bookworm-20231009-slim

# Install dependencies
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		curl ca-certificates libstfl-dev libsqlite3-dev \
		libcurl4 libcurl4-openssl-dev \
		pkg-config libxml2-dev libjson-c-dev asciidoctor gawk \
		libssl-dev libcrypt-dev gettext;

# Copy from builder
WORKDIR /newsboat
COPY --from=builder /newsboat/newsboat .

CMD ["/newsboat/newsboat",  "-c", "/data/cache.db",  "-C",  "/data/config", "-u", "/data/urls"]
