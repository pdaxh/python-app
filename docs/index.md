# Python Flask App

A production-ready Flask API that provides Hello World and date/time endpoints, fully containerized with Docker and deployable to Kubernetes via ArgoCD.

## Overview

The Python Flask App is a simple, production-ready REST API service that demonstrates:

- ✅ RESTful API endpoints
- ✅ Health checks for Kubernetes
- ✅ Docker containerization
- ✅ Kubernetes deployment via ArgoCD
- ✅ GitOps workflow integration

## Quick Links

- [Getting Started](getting-started.md) - Set up and run the application
- [API Reference](api-reference.md) - Complete API documentation
- [Deployment](deployment.md) - Deployment guides for different environments
- [Architecture](architecture.md) - System architecture and design
- [Troubleshooting](troubleshooting.md) - Common issues and solutions

## Features

- **Hello World endpoints** (`/`, `/hello`)
- **Date and time information** (`/datetime`, `/time`, `/date`)
- **Health checks** (`/health`) for Kubernetes probes
- **Docker containerization** with optimized Dockerfile
- **Kubernetes deployment** with Helm charts
- **ArgoCD integration** for GitOps workflows

## Technology Stack

- **Framework**: Flask (Python)
- **Containerization**: Docker
- **Orchestration**: Kubernetes
- **GitOps**: ArgoCD
- **Documentation**: TechDocs (MkDocs)

## Project Structure

```
python-app/
├── src/                    # Source code
│   ├── app.py             # Flask application
│   └── requirements.txt   # Python dependencies
├── Docker/                 # Docker configuration
│   └── Dockerfile         # Multi-stage Docker build
├── helm/                   # Helm charts
│   └── flask-app-chart/   # Helm chart for deployment
├── k8s/                   # Kubernetes manifests
├── docs/                  # Documentation (TechDocs)
│   ├── mkdocs.yml        # MkDocs configuration
│   └── *.md              # Documentation pages
└── catalog-info.yaml      # Backstage catalog definition
```

## Getting Help

- **Documentation**: See the navigation menu for detailed guides
- **Issues**: Report issues on [GitHub](https://github.com/pdaxh/python-app/issues)
- **Support**: Contact the ULP Platform Team

