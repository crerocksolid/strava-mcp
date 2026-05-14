# Multi-stage build for minimal final image
FROM --platform=$TARGETPLATFORM ghcr.io/astral-sh/uv:latest AS uv

FROM --platform=$TARGETPLATFORM python:3.11-slim AS builder

# Install uv for faster dependency management
COPY --from=uv /uv /usr/local/bin/uv

# Set working directory
WORKDIR /app

# Copy dependency files and README (needed for package metadata)
COPY pyproject.toml uv.lock* README.md ./

# Copy source code (needed for building the package)
COPY src/ ./src/

# Install dependencies into a virtual environment (including http extra for boto3/mangum)
RUN uv sync --frozen --no-dev --extra http

# Final stage - minimal runtime image
FROM --platform=$TARGETPLATFORM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /app/.venv /app/.venv

# Copy application code
COPY src/ ./src/
COPY pyproject.toml ./

# Set environment variables
ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Create directory for token storage
RUN mkdir -p /app/.strava_tokens

# Bind to all interfaces
ENV STRAVA_MCP_HOST=0.0.0.0

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import strava_mcp; print('ok')" || exit 1

# Use shell form so $PORT from Render is expanded at runtime
# Render injects PORT; fall back to 8000 for local dev
CMD STRAVA_MCP_PORT=${PORT:-8000} python -m strava_mcp.server --transport http
