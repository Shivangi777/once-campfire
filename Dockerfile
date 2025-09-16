# syntax=docker/dockerfile:1

# -----------------------
# Base Image
# -----------------------
ARG RUBY_VERSION=3.4.5
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Install system packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl libsqlite3-0 libvips libjemalloc2 ffmpeg redis build-essential git pkg-config libyaml-dev && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Set production environment
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development \
    LD_PRELOAD=/usr/local/lib/libjemalloc.so

# -----------------------
# Build stage
# -----------------------
FROM base AS build

# Copy Gemfiles and install gems
COPY Gemfile Gemfile.lock vendor ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy the rest of the app
COPY . .

# Precompile assets with dummy secret
RUN SECRET_KEY_BASE=dummy_secret_for_assets ./bin/rails assets:precompile

# -----------------------
# Final runtime stage
# -----------------------
FROM base

# Metadata
ARG OCI_DESCRIPTION
LABEL org.opencontainers.image.description="${OCI_DESCRIPTION}"
ARG OCI_SOURCE
LABEL org.opencontainers.image.source="${OCI_SOURCE}"
LABEL org.opencontainers.image.licenses="MIT"

# Create non-root user
RUN groupadd --system --gid 1000 rails && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash rails
USER 1000:1000

# Default environment variables for runtime
ENV HTTP_IDLE_TIMEOUT=60
ENV HTTP_READ_TIMEOUT=300
ENV HTTP_WRITE_TIMEOUT=300

# Copy gems and app from build stage
COPY --from=build --chown=rails:rails /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=rails:rails /rails /rails

# Expose HTTP and HTTPS ports
EXPOSE 80 443

# Start the app
CMD ["bin/boot"]
