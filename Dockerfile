FROM python:3-alpine

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /usr/src/app

RUN apk add --no-cache \
    gcc \
    musl-dev \
    mariadb-connector-c-dev \
    pkgconfig

RUN python -m venv virtualenv && source virtualenv/bin/activate

COPY requirements.txt ./

RUN pip install --no-cache-dir mysqlclient && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

RUN python manage.py collectstatic --noinput

RUN python manage.py setupdata

CMD [ "gunicorn", "webcrm.wsgi:application", "--bind", "0.0.0.0:8000",  "--workers", "3" ]