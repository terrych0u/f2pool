FROM python:3.9-slim-buster

WORKDIR /app

COPY . .

RUN apt-get update && \
    apt-get install -y libpq-dev gcc && \
    pip install --no-cache-dir -r requirements.txt

CMD [ "python", "main.py" ]
