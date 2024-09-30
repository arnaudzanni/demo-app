from flask import Flask, render_template_string, send_from_directory
import os

from azure.identity import ManagedIdentityCredential
from azure.storage.blob import BlobServiceClient

app = Flask(__name__)

IMAGES_FOLDER_PATH = os.path.join(os.getenv('APP_FOLDER_PATH'), "public")

def get_blob_url():
    storage_account_name = os.getenv('STORAGE_ACCOUNT_NAME')
    container_name = "public"
    blob_name = "hello-world.jpg"

    # Use managed identity credential to access Azure Blob Storage
    credential = ManagedIdentityCredential()
    blob_service_client = BlobServiceClient(
        f"https://{storage_account_name}.blob.core.windows.net",
        credential=credential
    )
    container_client = blob_service_client.get_container_client(container_name)

    # Get blob URL (assuming it's publicly accessible or credentials can read it)
    blob_client = container_client.get_blob_client(blob_name)
    return blob_client.url

    
@app.route('/')
def hello_world():
    environment = os.getenv('ENV', 'local')

    if environment == 'azure':
        image_url = get_blob_url()
        html_content = """
        <html>
            <body>
                <h1>Hello, World!</h1>
                <p>Image URL: {{ image_url }}</p>
                <img src="{{ image_url }}" alt="Hello World Image" />
            </body>
        </html>
        """
        return render_template_string(html_content, image_url=image_url)

    else:
        # Serve the local image from /public/hello-world.jpg
        local_image_path = '/public/hello-world.jpg'
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
@app.route('/public/<path:filename>')
def serve_public_file(filename):
    return send_from_directory(IMAGES_FOLDER_PATH, filename)
  
  
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)

@app.route('/')
def hello_world():
    return 'Hello, World!'