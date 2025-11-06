# Getting Started

This guide will help you get the Python Flask App up and running in different environments.

## Prerequisites

- **Python 3.11+** (for local development)
- **Docker** and Docker Compose
- **Kubernetes** cluster (minikube for local development)
- **kubectl** command-line tool
- **Helm** (for Kubernetes deployment)

## Local Development

### 1. Clone the Repository

```bash
git clone https://github.com/pdaxh/python-app.git
cd python-app
```

### 2. Install Dependencies

```bash
cd src
pip install -r requirements.txt
```

### 3. Run the Application

```bash
python app.py
```

The application will start on `http://localhost:8080`

### 4. Test the Endpoints

```bash
# Home endpoint
curl http://localhost:8080/

# Hello endpoint
curl http://localhost:8080/hello

# Health check
curl http://localhost:8080/health

# Date and time
curl http://localhost:8080/datetime
curl http://localhost:8080/time
curl http://localhost:8080/date
```

## Docker Deployment

### Build the Image

```bash
docker build -t python-app:latest -f Docker/Dockerfile .
```

### Run the Container

```bash
docker run -p 8080:8080 python-app:latest
```

### Test

```bash
curl http://localhost:8080/health
```

## Kubernetes Deployment

### Using Helm

```bash
# Deploy using Helm
cd helm/flask-app-chart
helm install python-app . --namespace python-app --create-namespace

# Check status
kubectl get pods -n python-app
```

### Using kubectl

```bash
# Apply Kubernetes manifests
kubectl apply -f k8s/

# Check deployment
kubectl get deployment,service -n python-app
```

### Access the Application

```bash
# Port forward to access locally
kubectl port-forward -n python-app svc/python-app 8080:8080

# Test
curl http://localhost:8080/health
```

## ArgoCD Deployment

The application is configured for GitOps deployment via ArgoCD:

1. **ArgoCD Application** is defined in `argocd-ULP/template/python-app.yaml`
2. **Helm Chart** is located in `helm/flask-app-chart/`
3. **Automatic Sync** is enabled for continuous deployment

### Deploy via ArgoCD

```bash
# Apply ArgoCD application
kubectl apply -f argocd-ULP/template/python-app.yaml

# Check sync status
kubectl get application python-app -n argocd
```

## Next Steps

- Read the [API Reference](api-reference.md) for detailed endpoint documentation
- Check [Deployment Guide](deployment.md) for production deployment
- Review [Architecture](architecture.md) for system design details

