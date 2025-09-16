# Flask API with Kubernetes Deployment

A production-ready Flask API that provides Hello World and date/time endpoints, fully containerized with Docker and deployable to Kubernetes.

## Features

- **Hello World endpoints** (`/`, `/hello`)
- **Date and time information** (`/datetime`, `/time`, `/date`)
- **Docker containerization** with optimized Dockerfile
- **Kubernetes deployment** with proper manifests
- **Ingress configuration** for clean URL routing
- **Production-ready** structure and configuration

## Project Structure

```
python-app/
├── src/                    # Source code
│   ├── app.py             # Flask application
│   ├── requirements.txt   # Python dependencies
│   └── .dockerignore      # Docker ignore file
├── Docker/                 # Docker configuration
│   └── Dockerfile         # Multi-stage Docker build
├── k8s/                   # Kubernetes manifests
│   ├── deployment.yaml    # Flask app deployment
│   ├── service.yaml       # Internal service
│   └── ingress.yaml       # External access
├── scripts/                # Deployment scripts
│   └── deploy.sh          # Kubernetes deployment script
├── Makefile               # Build and deploy commands
└── README.md              # This file
```

## API Endpoints

### Hello World
- `GET /` - Returns Hello World message
- `GET /hello` - Returns Hello World message

### Date and Time
- `GET /datetime` - Current date, time, and timestamp
- `GET /time` - Current time only
- `GET /date` - Current date with day and month names

## Prerequisites

- **Python 3.11+**
- **Docker** with Docker Compose
- **Kubernetes** (minikube for local development)
- **kubectl** command-line tool

## Quick Start

### 1. Local Development

```bash
# Clone the repository
git clone <your-repo-url>
cd python-app

# Install dependencies
cd src
pip install -r requirements.txt

# Run locally
python app.py
```

**Test locally:**
```bash
curl http://localhost:8080/
curl http://localhost:8080/datetime
```

### 2. Docker Deployment

```bash
# Build Docker image
cd python-app
make build

# Or manually
docker build -t danielaxhammar/flask-app:v2 Docker/

# Run container
docker run -p 8080:8080 danielaxhammar/flask-app:v2
```

**Test Docker:**
```bash
curl http://localhost:8080/
curl http://localhost:8080/datetime
```

### 3. Kubernetes Deployment

```bash
# Start minikube (if not running)
minikube start

# Deploy to Kubernetes
cd python-app
make deploy

# Or manually
kubectl apply -f k8s/
```

**Set up local access:**
```bash
# Add hostname to /etc/hosts
echo "127.0.0.1 flask-app.local" | sudo tee -a /etc/hosts

# Port forward Ingress controller
kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80
```

**Test Kubernetes deployment:**
```bash
# Test all endpoints
curl -H "Host: flask-app.local" http://localhost:8080/
curl -H "Host: flask-app.local" http://localhost:8080/hello
curl -H "Host: flask-app.local" http://localhost:8080/datetime
curl -H "Host: flask-app.local" http://localhost:8080/time
curl -H "Host: flask-app.local" http://localhost:8080/date
```

## Docker Commands

```bash
# Build image
make build

# Run container
docker run -p 8080:8080 danielaxhammar/flask-app:v2

# Push to registry
docker tag danielaxhammar/flask-app:v2 your-registry/flask-app:v2
docker push your-registry/flask-app:v2
```

## Kubernetes Commands

```bash
# Deploy
make deploy

# Check status
kubectl get deployment,service,ingress
kubectl get pods

# View logs
kubectl logs -l app=flask-app

# Clean up
make clean
# Or manually
kubectl delete -f k8s/
```

## API Response Examples

### Hello World
```json
{
  "message": "Hello World!"
}
```

### DateTime
```json
{
  "date": "2024-01-15",
  "time": "14:30:25",
  "datetime": "2024-01-15 14:30:25",
  "timestamp": 1705327825.123456
}
```

### Time
```json
{
  "current_time": "14:30:25",
  "timezone": "local"
}
```

### Date
```json
{
  "current_date": "2024-01-15",
  "day_of_week": "Monday",
  "month": "January"
}
```

## Configuration

### Environment Variables
- `FLASK_APP=app.py` - Flask application entry point
- `FLASK_ENV=production` - Environment mode
- `FLASK_RUN_HOST=0.0.0.0` - Bind to all interfaces
- `FLASK_RUN_PORT=8080` - Application port

### Kubernetes Resources
- **Memory**: 64Mi request, 128Mi limit
- **CPU**: 50m request, 100m limit
- **Replicas**: 1 (configurable in deployment.yaml)

## Deployment Options

### 1. **Local Development**
- Direct Python execution
- Port 8080 on localhost

### 2. **Docker Container**
- Containerized application
- Port mapping: 8080:8080

### 3. **Kubernetes (Local)**
- minikube cluster
- Ingress routing with port forwarding
- Clean URLs: `http://localhost:8080/`

### 4. **Kubernetes (Production)**
- Production cluster deployment
- Load balancer integration
- SSL/TLS termination
- Auto-scaling capabilities

## Testing

```bash
# Test all endpoints
make test

# Manual testing
curl -H "Host: flask-app.local" http://localhost:8080/
curl -H "Host: flask-app.local" http://localhost:8080/datetime
curl -H "Host: flask-app.local" http://localhost:8080/time
curl -H "Host: flask-app.local" http://localhost:8080/date
```

## Makefile Commands

```bash
make build    # Build Docker image
make deploy   # Deploy to Kubernetes
make clean    # Clean up deployment
make test     # Test all endpoints
make help     # Show available commands
```

## Troubleshooting

### Common Issues

1. **Port 80 permission denied**
   - Use higher port (8080, 3000) for port forwarding
   - `kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80`

2. **Connection refused**
   - Ensure minikube is running: `minikube status`
   - Check pod status: `kubectl get pods`
   - Verify service: `kubectl get services`

3. **Host not found**
   - Add to /etc/hosts: `127.0.0.1 flask-app.local`
   - Use `-H "Host: flask-app.local"` in curl commands

### Debug Commands

```bash
# Check deployment status
kubectl describe deployment flask-app

# Check pod logs
kubectl logs -l app=flask-app

# Check service endpoints
kubectl get endpoints flask-app

# Check ingress status
kubectl describe ingress flask-app-ingress
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flask framework for the web framework
- Kubernetes for container orchestration
- minikube for local Kubernetes development
- Docker for containerization

---

**Happy coding!**
