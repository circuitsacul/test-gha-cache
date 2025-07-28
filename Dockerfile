# syntax=docker/dockerfile:1.7-labs
ARG APP_NAME=test-gha-cache

FROM rust:1.88-bookworm AS builder
ARG APP_NAME
WORKDIR /app

COPY . .
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/app/target \
    cargo build --release --bin ${APP_NAME} \
    && mv /app/target/release/${APP_NAME} /usr/local/bin

FROM gcr.io/distroless/cc-debian12:nonroot AS runtime
ARG APP_NAME
WORKDIR /app
COPY --from=builder /usr/local/bin/${APP_NAME} /usr/local/bin/app
USER nonroot:nonroot
ENTRYPOINT ["/usr/local/bin/app"]
