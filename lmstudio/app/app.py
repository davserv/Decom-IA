"""
LM Chat — Servidor Flask para chat com IA local via LM Studio
Rodar: python app.py
Acessar: http://localhost:5000
"""

import json
import os
import uuid
import time
import requests
from flask import Flask, render_template, request, jsonify, Response, stream_with_context

app = Flask(__name__)

# ======================= Configurações =======================
DATA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data')
CONVERSATIONS_FILE = os.path.join(DATA_DIR, 'conversations.json')
SETTINGS_FILE = os.path.join(DATA_DIR, 'settings.json')

DEFAULT_SETTINGS = {
    'url': 'http://localhost:1234',
    'model': '',
    'temperature': 0.7,
    'max_tokens': 2048,
    'top_p': 0.9,
    'system_prompt': 'Voce e um assistente de IA util, respeitoso e honesto. '
                     'Responda sempre em portugues brasileiro, a menos que o '
                     'usuario peca em outro idioma. Use markdown para formatar '
                     'suas respostas.',
    'context_length': 20,
}

# ======================= Persistência =======================

def ensure_data_dir():
    """Cria o diretório data/ se não existir."""
    os.makedirs(DATA_DIR, exist_ok=True)


def load_json(filepath, default):
    """Carrega JSON de arquivo, retorna default se não existir."""
    if os.path.exists(filepath):
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                return json.load(f)
        except (json.JSONDecodeError, IOError):
            return default
    return default


def save_json(filepath, data):
    """Salva dados em arquivo JSON."""
    ensure_data_dir()
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def load_conversations():
    return load_json(CONVERSATIONS_FILE, [])


def save_conversations(convs):
    save_json(CONVERSATIONS_FILE, convs)


def load_settings():
    saved = load_json(SETTINGS_FILE, {})
    merged = {**DEFAULT_SETTINGS, **saved}
    return merged


def save_settings(data):
    save_json(SETTINGS_FILE, data)


# ======================= Rotas — Páginas =======================

@app.route('/')
def index():
    """Serve a página principal do chat."""
    return render_template('index.html')


# ======================= Rotas — API LM Studio (Proxy) =======================

@app.route('/api/models', methods=['GET'])
def get_models():
    """Lista modelos disponíveis no LM Studio."""
    settings = load_settings()
    try:
        resp = requests.get(
            f"{settings['url']}/v1/models",
            timeout=5
        )
        resp.raise_for_status()
        return jsonify(resp.json())
    except requests.exceptions.ConnectionError:
        return jsonify({'error': 'Nao foi possivel conectar ao LM Studio. '
                                 'Verifique se esta rodando.'}), 503
    except requests.exceptions.Timeout:
        return jsonify({'error': 'Timeout ao conectar ao LM Studio.'}), 504
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/health', methods=['GET'])
def health_check():
    """Verifica se o LM Studio está acessível."""
    settings = load_settings()
    try:
        resp = requests.get(
            f"{settings['url']}/v1/models",
            timeout=3
        )
        resp.raise_for_status()
        data = resp.json()
        model_count = len(data.get('data', []))
        return jsonify({
            'connected': True,
            'model_count': model_count,
            'models': [m.get('id', '') for m in data.get('data', [])]
        })
    except Exception:
        return jsonify({'connected': False, 'model_count': 0, 'models': []})


@app.route('/api/chat', methods=['POST'])
def chat_completions():
    """
    Proxy para o endpoint de chat completions do LM Studio.
    Suporta streaming e non-streaming.
    """
    settings = load_settings()
    body = request.json or {}

    # Monta o payload para o LM Studio
    payload = {
        'model': body.get('model', settings['model']),
        'messages': body.get('messages', []),
        'temperature': body.get('temperature', settings['temperature']),
        'max_tokens': body.get('max_tokens', settings['max_tokens']),
        'top_p': body.get('top_p', settings['top_p']),
        'stream': body.get('stream', True),
    }

    try:
        if payload['stream']:
            # Streaming: repassa os chunks SSE do LM Studio
            return Response(
                stream_with_context(proxy_stream(settings['url'], payload)),
                content_type='text/event-stream',
                headers={
                    'Cache-Control': 'no-cache',
                    'X-Accel-Buffering': 'no',
                    'Connection': 'keep-alive',
                }
            )
        else:
            # Non-streaming: requisição simples
            resp = requests.post(
                f"{settings['url']}/v1/chat/completions",
                json=payload,
                timeout=120
            )
            resp.raise_for_status()
            return jsonify(resp.json())

    except requests.exceptions.ConnectionError:
        return jsonify({'error': 'Nao foi possivel conectar ao LM Studio.'}), 503
    except requests.exceptions.Timeout:
        return jsonify({'error': 'Timeout na geracao de resposta.'}), 504
    except Exception as e:
        return jsonify({'error': str(e)}), 500


def proxy_stream(base_url, payload):
    """
    Faz streaming da resposta do LM Studio e repassa
    cada chunk como Server-Sent Event para o navegador.
    """
    try:
        resp = requests.post(
            f"{base_url}/v1/chat/completions",
            json=payload,
            stream=True,
            timeout=120
        )
        resp.raise_for_status()

        for line in resp.iter_lines(decode_unicode=True):
            if line:
                # Repassa a linha do SSE do LM Studio
                yield line + '\n\n'

    except requests.exceptions.ConnectionError:
        error_data = json.dumps({
            'error': 'Conexao perdida com o LM Studio.'
        })
        yield f"data: {error_data}\n\n"
    except requests.exceptions.Timeout:
        error_data = json.dumps({
            'error': 'Timeout na geracao de resposta.'
        })
        yield f"data: {error_data}\n\n"
    except Exception as e:
        error_data = json.dumps({'error': str(e)})
        yield f"data: {error_data}\n\n"


# ======================= Rotas — Conversas =======================

@app.route('/api/conversations', methods=['GET'])
def list_conversations():
    """Lista todas as conversas (sem o conteúdo das mensagens para leveza)."""
    convs = load_conversations()
    # Retorna resumo: id, title, createdAt, messageCount
    summary = []
    for c in convs:
        summary.append({
            'id': c.get('id', ''),
            'title': c.get('title', 'Nova Conversa'),
            'createdAt': c.get('createdAt', 0),
            'messageCount': len(c.get('messages', [])),
        })
    return jsonify(summary)


@app.route('/api/conversations', methods=['POST'])
def create_conversation():
    """Cria uma nova conversa."""
    convs = load_conversations()
    conv = {
        'id': uuid.uuid4().hex[:12],
        'title': 'Nova Conversa',
        'messages': [],
        'createdAt': int(time.time() * 1000),
    }
    convs.insert(0, conv)
    save_conversations(convs)
    return jsonify(conv), 201


@app.route('/api/conversations/<conv_id>', methods=['GET'])
def get_conversation(conv_id):
    """Retorna uma conversa completa com mensagens."""
    convs = load_conversations()
    conv = next((c for c in convs if c['id'] == conv_id), None)
    if not conv:
        return jsonify({'error': 'Conversa nao encontrada.'}), 404
    return jsonify(conv)


@app.route('/api/conversations/<conv_id>', methods=['PUT'])
def update_conversation(conv_id):
    """Atualiza título ou mensagens de uma conversa."""
    convs = load_conversations()
    conv = next((c for c in convs if c['id'] == conv_id), None)
    if not conv:
        return jsonify({'error': 'Conversa nao encontrada.'}), 404

    data = request.json or {}
    if 'title' in data:
        conv['title'] = data['title']
    if 'messages' in data:
        conv['messages'] = data['messages']

    save_conversations(convs)
    return jsonify(conv)


@app.route('/api/conversations/<conv_id>', methods=['DELETE'])
def delete_conversation(conv_id):
    """Remove uma conversa."""
    convs = load_conversations()
    convs = [c for c in convs if c['id'] != conv_id]
    save_conversations(convs)
    return jsonify({'success': True})


@app.route('/api/conversations/<conv_id>/messages', methods=['POST'])
def add_message(conv_id):
    """Adiciona uma mensagem a uma conversa."""
    convs = load_conversations()
    conv = next((c for c in convs if c['id'] == conv_id), None)
    if not conv:
        return jsonify({'error': 'Conversa nao encontrada.'}), 404

    data = request.json or {}
    msg = {
        'id': uuid.uuid4().hex[:8],
        'role': data.get('role', 'user'),
        'content': data.get('content', ''),
        'timestamp': int(time.time() * 1000),
    }
    conv['messages'].append(msg)

    # Atualiza título automaticamente na primeira mensagem
    if len(conv['messages']) == 1 and msg['role'] == 'user':
        conv['title'] = msg['content'][:50] + ('...' if len(msg['content']) > 50 else '')

    save_conversations(convs)
    return jsonify(msg), 201


# ======================= Rotas — Configurações =======================

@app.route('/api/settings', methods=['GET'])
def get_settings():
    """Retorna as configurações atuais."""
    return jsonify(load_settings())


@app.route('/api/settings', methods=['PUT'])
def update_settings():
    """Atualiza as configurações."""
    data = request.json or {}
    current = load_settings()

    # Mescla apenas chaves conhecidas
    for key in DEFAULT_SETTINGS:
        if key in data:
            current[key] = data[key]

    save_settings(current)
    return jsonify(current)


# ======================= Rotas — Exportar/Importar =======================

@app.route('/api/export', methods=['GET'])
def export_conversations():
    """Exporta todas as conversas como JSON."""
    convs = load_conversations()
    return jsonify({
        'version': 1,
        'exportedAt': int(time.time() * 1000),
        'conversations': convs
    })


@app.route('/api/import', methods=['POST'])
def import_conversations():
    """Importa conversas de um JSON."""
    data = request.json or {}
    imported = data.get('conversations', [])
    if not isinstance(imported, list):
        return jsonify({'error': 'Formato invalido.'}), 400

    current = load_conversations()
    existing_ids = {c['id'] for c in current}

    added = 0
    for conv in imported:
        if conv.get('id') not in existing_ids:
            current.append(conv)
            added += 1

    # Reordena por data
    current.sort(key=lambda c: c.get('createdAt', 0), reverse=True)
    save_conversations(current)

    return jsonify({'imported': added, 'total': len(current)})


# ======================= Main =======================

if __name__ == '__main__':
    ensure_data_dir()
    print()
    print("=" * 50)
    print("  LM Chat — Servidor Flask")
    print("  Acesse: http://localhost:5000")
    print("  LM Studio: http://localhost:1234")
    print("=" * 50)
    print()
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=True,
        threaded=True
    )