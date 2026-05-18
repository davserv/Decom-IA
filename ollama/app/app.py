# app.py
from flask import Flask, request, Response, jsonify, send_from_directory
from flask_cors import CORS
import requests
import json
import os

app = Flask(__name__, static_folder='.')
CORS(app)

# Rota principal: Serve o frontend
@app.route('/')
def serve_index():
    return send_from_directory('.', 'index.html')

@app.route('/api/chat', methods=['POST'])
def proxy_chat():
    data = request.json
    provider = data.get('provider', 'ollama')
    model = data.get('model', '')
    messages = data.get('messages', [])
    api_key = data.get('apiKey', '')
    ollama_url = data.get('ollamaUrl', 'http://localhost:11434')
    
    options = data.get('options', {})
    
    payload = {
        "model": model,
        "messages": messages,
        "stream": True,
        "options": options
    }
    
    headers = {"Content-Type": "application/json"}

    if provider == 'ollama_cloud':
        if not api_key:
            return jsonify({"error": "A API Key é obrigatória para o Ollama Cloud"}), 400
        headers["Authorization"] = f"Bearer {api_key}"
        target_url = "https://ollama.com/api/chat"
    else:
        target_url = f"{ollama_url}/api/chat"
        
    try:
        resp = requests.post(target_url, headers=headers, json=payload, stream=True)
        resp.raise_for_status()
        
        def generate():
            for line in resp.iter_lines():
                if line:
                    yield line.decode('utf-8') + '\n'
                    
        return Response(generate(), mimetype='text/event-stream')
        
    except requests.exceptions.RequestException as e:
        error_msg = str(e)
        try:
            error_msg = e.response.json().get('error', error_msg)
        except:
            pass
        return jsonify({"error": f"Erro na API: {error_msg}"}), 500

@app.route('/api/models', methods=['POST'])
def get_models():
    provider = request.json.get('provider', 'ollama')
    api_key = request.json.get('apiKey', '')
    ollama_url = request.json.get('ollamaUrl', 'http://localhost:11434')
    
    headers = {}
    target_url = ""

    if provider == 'ollama_cloud':
        if not api_key:
            return jsonify({"models": []})
        headers["Authorization"] = f"Bearer {api_key}"
        target_url = "https://ollama.com/api/tags"
    else:
        target_url = f"{ollama_url}/api/tags"

    try:
        resp = requests.get(target_url, headers=headers, timeout=5)
        if resp.status_code == 200:
            models = [m["name"] for m in resp.json().get("models", [])]
            return jsonify({"models": models})
        return jsonify({"models": []})
    except:
        return jsonify({"models": []})

if __name__ == '__main__':
    # host='0.0.0.0' é OBRIGATÓRIO para o Codespaces conseguir fazer o port forwarding
    app.run(host='0.0.0.0', port=5000, debug=True)