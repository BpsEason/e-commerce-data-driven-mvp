# Use a base image with Python
FROM python:3.9-slim-buster

# Set the working directory
WORKDIR /app

# Copy requirements file and install dependencies
COPY ./requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy the rest of the application code
COPY ./app /app/app
COPY ./data /app/data

# Expose the port FastAPI runs on
EXPOSE 8001

# Command to run the application using uvicorn
# Make sure to run with --host 0.0.0.0 to be accessible from outside the container
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8001"]
