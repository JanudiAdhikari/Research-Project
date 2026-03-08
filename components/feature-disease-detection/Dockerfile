FROM mcr.microsoft.com/devcontainers/python:1-3.11-bullseye AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    TF_CPP_MIN_LOG_LEVEL=2

WORKDIR /app

RUN apt-get update \
    ; apt-get install -y --no-install-recommends libglib2.0-0 libgl1 \
    ; rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --upgrade pip \
    ; pip install -r requirements.txt

COPY . .

RUN useradd -m appuser \
    ; chown -R appuser:appuser /app
USER appuser

EXPOSE 5001

CMD ["python", "app.py"]
