FROM python:alpine

ENV RANDOMIZER_CONFIG=/app/randomizer.yml

USER root
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk update && \
    apk add docker-cli-compose

RUN addgroup -g 988 docker
RUN adduser -D -H randomizer && \
    adduser randomizer docker
RUN mkdir /app && chown randomizer:randomizer /app

USER randomizer
WORKDIR /app
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD pgrep -f "randomizer" || exit 1

RUN python -m venv /app/venv
ENV PATH="/app/venv/bin:${PATH}"
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY randomizer .
COPY randomizer.yml .

ENTRYPOINT ["sh", "-c"]

CMD ["python /app/randomizer --config $RANDOMIZER_CONFIG"]
