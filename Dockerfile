# syntax=docker/dockerfile:1

FROM alpine:3.24 AS base

WORKDIR /app

# Set environment variables for non-interactive installs and minimal locale.
# HOST/PORT are the defaults the server already uses; they are declared here so the
# image is self-documenting and keeps binding to all interfaces.
ENV LANG=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    HOST=0.0.0.0 \
    PORT=8000

# Install the runtime packages (tini as PID 1, curl for health checks)
RUN apk add --no-cache \
        bash \
        curl \
        tini \
        coreutils

# Set tini as the init system to handle PID 1
ENTRYPOINT ["/sbin/tini", "--"]

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Ensure uv is on PATH (installer places it in /root/.local/bin for root)
ENV PATH="/root/.local/bin:${PATH}"

COPY .python-version .

# Create the virtual environment up front so the managed interpreter is cached in the
# base image and available to the runner stage, which copies the venv from the builder.
RUN uv venv

FROM base AS builder

# git is only needed for uv-dynamic-versioning while building the project
RUN apk add --no-cache git

COPY . .

# Install from the lockfile so the runtime matches what is tested, and use a
# non-editable install so the virtual environment is self-contained and portable.
RUN uv sync --locked --no-dev --no-editable

FROM base AS runner

# Reuse the exact dependency set resolved in the builder instead of re-resolving it
# from PyPI at image build time.
COPY --from=builder /app/.venv /app/.venv

EXPOSE 8000

CMD ["uv", "run", "mcp-google-sheets", "--transport", "sse"]
