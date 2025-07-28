# syntax=docker/dockerfile:1.7-labs
ARG APP_NAME=test-gha-cache

FROM rust:1.88-bookworm AS chef
WORKDIR /app
RUN cargo install cargo-chef

FROM chef AS planner
COPY . .
RUN --mount=type=cache,id=cargo-registry,target=/usr/local/cargo/registry \
    --mount=type=cache,id=cargo-git,target=/usr/local/cargo/git \
    --mount=type=cache,id=cargo-target,target=/app/target \
    cargo chef prepare --recipe-path recipe.json

FROM chef AS builder 
ARG APP_NAME
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json --bin ${APP_NAME}
COPY . .
RUN --mount=type=cache,id=cargo-registry,target=/usr/local/cargo/registry \
    --mount=type=cache,id=cargo-git,target=/usr/local/cargo/git \
    --mount=type=cache,id=cargo-target,target=/app/target \
    cargo build --release --bin ${APP_NAME} \
    && mv /app/target/release/${APP_NAME} /usr/local/bin

FROM gcr.io/distroless/cc-debian12:nonroot AS runtime
ARG APP_NAME
WORKDIR /app
COPY --from=builder /usr/local/bin/${APP_NAME} /usr/local/bin/app
USER nonroot:nonroot
ENTRYPOINT ["/usr/local/bin/app"]
