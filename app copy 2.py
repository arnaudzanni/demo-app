import os

import requests
from azure.identity import ManagedIdentityCredential
from azure.storage.blob import BlobServiceClient
from flask import Flask, render_template_string, send_from_directory
from sqlalchemy import create_engine, text

app = Flask(__name__)


@app.route("/")
def hello_world():
    html_content = """
    <html>
        <body>
            <h1>Hello, World! v3 2025</h1>
        </body>
    </html>
    """
    return render_template_string(html_content)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
