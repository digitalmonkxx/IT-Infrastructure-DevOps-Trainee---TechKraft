from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello TechKraft, I am interested in becoming one of krafters."

app.run(host="0.0.0.0", port=5000)

