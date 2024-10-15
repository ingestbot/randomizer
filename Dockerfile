FROM python:alpine

ENV RANDOMIZER_CONFIG=/app/randomizer.yml
RUN adduser -D -H randomizer
RUN mkdir /app && chown randomizer:randomizer /app
# USER randomizer
USER root

RUN apk add --no-cache docker-cli-compose

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
