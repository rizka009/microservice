FROM python:3.10-slim
WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 3006
ENV FLASK_ENV=production
CMD ["python", "app.py"]