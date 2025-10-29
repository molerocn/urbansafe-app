FROM python:3.11-slim
WORKDIR /app

# Install dependencies
COPY requirements.txt /app/requirements.txt
RUN python -m pip install --upgrade pip && \
    python -m pip install --no-cache-dir -r /app/requirements.txt

# Copy service code
COPY . /app

ENV PORT=8080
EXPOSE 8080

# Use Uvicorn to serve the FastAPI app
CMD ["uvicorn", "ml_service.app.main:app", "--host", "0.0.0.0", "--port", "8080"]
