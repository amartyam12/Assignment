from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
<<<<<<< HEAD
    return "Hello world"
=======
    return "Hello world12345"
>>>>>>> 7f2aa8ddbd4b6bffe05a3e8712bfa35f9f6c6113

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
