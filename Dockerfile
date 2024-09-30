# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements.txt file into the container
COPY requirements.txt ./

# Install the required Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY app.py ./

# Expose port 8080 for the Flask app
EXPOSE 8080

# Set environment variable
ENV ENV=azure
ENV APP_FOLDER_PATH=/app
ENV STORAGE_ACCOUNT_NAME=planetscoresa
ENV FLASK_APP=app.py
ENV FLASK_ENV=development

# Run the Flask app
CMD ["python", "app.py"]
