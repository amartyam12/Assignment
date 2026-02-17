#gitar auto-apply:on
#gitar display:verbose         

from flask import Flas

app = Flask(__name__)
#Done

@app.route("/")
def home():

    return "Complete"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
