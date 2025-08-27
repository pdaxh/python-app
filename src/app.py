from flask import Flask
from datetime import datetime


app = Flask(__name__)

@app.route('/')
def hello_world():
    return {'message': 'Hello World!'}

@app.route('/hello')
def hello():
    return {'message': 'Hello World!'}

@app.route('/health')
def health_check():
    """Lightweight health check endpoint for Kubernetes probes"""
    return {'status': 'healthy'}, 200

@app.route('/datetime')
def get_datetime():
    now = datetime.now()
    return {
        'date': now.strftime('%Y-%m-%d'),
        'time': now.strftime('%H:%M:%S'),
        'datetime': now.strftime('%Y-%m-%d %H:%M:%S'),
        'timestamp': now.timestamp()
    }

@app.route('/time')
def get_time():
    now = datetime.now()
    return {
        'current_time': now.strftime('%H:%M:%S'),
        'timezone': 'local'
    }

@app.route('/date')
def get_date():
    now = datetime.now()
    return {
        'current_date': now.strftime('%Y-%m-%d'),
        'day_of_week': now.strftime('%A'),
        'month': now.strftime('%B')
    }

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)
