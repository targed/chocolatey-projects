from flask import Flask, render_template, request, jsonify
import json
import os
import urllib.parse
from find_missing_packages import search_github_repos, check_windows_assets, calculate_ease, check_chocolatey, generate_package

app = Flask(__name__, template_folder='templates_web')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/results', methods=['GET'])
def get_results():
    if os.path.exists('results.json'):
        try:
            with open('results.json', 'r', encoding='utf-8') as f:
                data = json.load(f)
            return jsonify(data)
        except Exception as e:
            return jsonify({"error": str(e)}), 500
    return jsonify([])

@app.route('/api/generate', methods=['POST'])
def generate():
    data = request.json
    url = data.get('url')
    if not url:
        return jsonify({"success": False, "message": "No URL provided"}), 400

    try:
        # We need to ensure generate_package uses the absolute paths or correct relative paths when run from flask
        generate_package(url)
        return jsonify({"success": True, "message": f"Package successfully scaffolded from {url}"})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=8000)
