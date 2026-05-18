from flask import Flask, render_template, request, Response
import requests
import json

app = Flask(__name__)

OLLAMA_API_URL = "http://localhost:11434/api/chat"

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/chat", methods=["POST"])
def chat():
    # Agora recebemos uma lista de mensagens (histórico)
    messages = request.json.get("messages")
    
    payload = {
        "model": "qwen3:1.7b", 
        "messages": messages, # Envia o histórico completo para o Ollama
        "stream": True
    }

    try:
        response = requests.post(OLLAMA_API_URL, json=payload, stream=True)
        
        def generate():
            for line in response.iter_lines():
                if line:
                    data = json.loads(line)
                    if "message" in data and "content" in data["message"]:
                        chunk = data["message"]["content"]
                        yield f"data: {json.dumps({'text': chunk})}\n\n"
                    if data.get("done"):
                        break

        return Response(generate(), mimetype="text/event-stream")

    except Exception as e:
        return {"error": str(e)}, 500

if __name__ == "__main__":
    app.run(debug=True, port=5000)