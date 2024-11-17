import os

import requests
from azure.identity import ManagedIdentityCredential
from azure.storage.blob import BlobServiceClient
from flask import Flask, render_template_string, send_from_directory

app = Flask(__name__)

IMAGES_FOLDER_PATH = os.path.join(os.getenv("APP_FOLDER_PATH"), "public")

# The backend URL can be configured using an environment variable
BACKEND_URL = os.getenv("BACKEND_URL", "http://host.docker.internal:5000/api/items")


def get_blob_url():
    storage_account_name = os.getenv("STORAGE_ACCOUNT_NAME")
    container_name = "public"
    blob_name = "hello-world.jpg"

    # Use managed identity credential to access Azure Blob Storage
    credential = ManagedIdentityCredential()
    blob_service_client = BlobServiceClient(
        f"https://{storage_account_name}.blob.core.windows.net", credential=credential
    )
    container_client = blob_service_client.get_container_client(container_name)

    # Get blob URL (assuming it's publicly accessible or credentials can read it)
    blob_client = container_client.get_blob_client(blob_name)
    return blob_client.url


@app.route("/")
def hello_world():
    environment = os.getenv("ENV", "local")

    if environment == "azure":
        image_url = get_blob_url()
        error_message = ""
        items="{}"
        try:
            response = requests.get(BACKEND_URL)
            response.raise_for_status()  # Raise an error for bad responses (4xx, 5xx)
            items = response.json()
        except Exception as e:
            # Catch any exceptions, including connectivity issues or bad responses
            error_message = f"Error while contacting backend: {str(e)}"
        # Example: reading a file from the mounted volume (/app/data)
        try:
            with open('/app/data/test.txt', 'r') as file:
                file_content = file.read()
            file_share_message = f"File content: {file_content}"
        except Exception as e:
            file_share_message = f"Error: {str(e)}"
        
        html_content = """
        <html>
            <body>
                <h1>Hello, World! v3 2025</h1>
                <h2>Backend URL:</h2>
                <p>{{ backend_url }}</p>
                <p>{{ items }}</p>
                <p>{{ image_url }}</p>
                <p>{{ images_folder_path }}</p>
                <p>File Share message: {{ file_share_message }}</p>
                <h2>Items from Backend:</h2>
                {% if items %}
                    <ul>
                    {% for item in items %}
                        <li>{{ item['name'] }}</li>
                    {% endfor %}
                    </ul>
                {% else %}
                    <p>No items available or backend is not reachable.</p>
                    <p>Error Message: {{ error_message }}</p>
                {% endif %}
                <p>Image URL: {{ image_url }}</p>
                <img src="{{ image_url }}" alt="Hello World Image" />
            </body>
        </html>
        """
        return render_template_string(html_content,
            backend_url=BACKEND_URL,
            items=items,
            error_message=error_message,
            images_folder_path=IMAGES_FOLDER_PATH,
            file_share_message=file_share_message,
            image_url=image_url)

    else:
        # Serve the local image from /public/hello-world.jpg
        local_image_path = "/public/hello-world.jpg"
        html_content = """
        <html>
            <body>
                <h1>Hello, World!</h1>
                <p>Image Path: {{ local_image_path }}</p>
                <img src="{{ local_image_path }}" alt="Hello World Image" />
            </body>
        </html>
        """
        return render_template_string(html_content, local_image_path=local_image_path)


# Route to serve files from /app/public directory
@app.route("/public/<path:filename>")
def serve_public_file(filename):
    return send_from_directory(IMAGES_FOLDER_PATH, filename)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
