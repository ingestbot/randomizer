FROM python:3.12-slim

ENV RANDOMIZER_CONFIG=/app/randomizer.yml

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg procps && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | \
        gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) \
        signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
        > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        docker-ce-cli docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g 988 docker && \
    groupadd -g 1000 randomizer && \
    useradd -m -u 1000 -g randomizer randomizer && \
    usermod -aG docker randomizer

RUN mkdir /app && chown randomizer:randomizer /app

USER randomizer
WORKDIR /app

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD pgrep -f "randomizer" || exit 1

RUN python -m venv /app/venv
ENV PATH="/app/venv/bin:${PATH}"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY randomizer .
COPY randomizer.yml .

ENTRYPOINT ["sh", "-c"]
CMD ["python /app/randomizer --config $RANDOMIZER_CONFIG"]
