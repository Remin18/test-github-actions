# syntax=docker/dockerfile:1
FROM python:3.12-slim

WORKDIR /app

# キャッシュを活かすために分割してコピー
COPY app/ /app/

EXPOSE 8000

CMD ["python", "-m", "http.server", "8000"]
