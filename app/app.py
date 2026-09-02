from flask import Flask, jsonify
import requests

app = Flask(__name__)

def get_meta(path):
    try:
        r = requests.get(f"http://169.254.169.254/latest/meta-data/{path}", timeout=1)
        return r.text
    except:
        return "local"

@app.route("/")
def index():
    return jsonify({
        "instance_id": get_meta("instance-id"),
        "az": get_meta("placement/availability-zone"),
        "health": "healthy"
    })

@app.route("/health")
def health():
    return jsonify(status="ok"), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)