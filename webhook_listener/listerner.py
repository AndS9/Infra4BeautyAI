from flask import Flask, request
import subprocess
import json

app = Flask(__name__)


@app.route("/webhook", methods=["POST"])
def webhook():
    # Only react to GitHub push events
    data = request.get_json()

    print(data.get("ref"))

    if data.get("ref") == "refs/heads/develop":
        print(data.get("ref"), "  Restarting backend service")
        try:
            subprocess.Popen(
                ["sudo", "systemctl", "restart", "backend.service"],
            )
        except subprocess.CalledProcessError as e:
            return f"Failed to restart service: {e}\n", 500
    elif data.get("ref") == "refs/heads/frontend":
        print(data.get("ref"), "  Restarting frontend service")
        try:
            subprocess.Popen(
                ["sudo", "systemctl", "restart", "frontend.service"],
            )
        except subprocess.CalledProcessError as e:
            return f"Failed to restart service: {e}\n", 500
    else:
        return "Ignored", 200
    
    return "OK" , 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=7070)