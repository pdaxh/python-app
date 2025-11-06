# Deployment Guide

This guide covers deploying the Python Flask App to different environments.

## Deployment Options

### 1. Local Development

Direct Python execution for development and testing.

**Steps:**
```bash
cd src
pip install -r requirements.txt
python app.py
```

**Access:** `http://localhost:8080`

### 2. Docker

Containerized deployment using Docker.

**Build:**
```bash
docker build -t python-app:latest -f Docker/Dockerfile .
```

**Run:**
```bash
docker run -p 8080:8080 python-app:latest
```

**Access:** `http://localhost:8080`

### 3. Kubernetes (Helm)

Deploy using Helm chart for Kubernetes.

**Deploy:**
```bash
cd helm/flask-app-chart
helm install python-app . \
  --namespace python-app \
  --create-namespace \
  --set image.tag=latest
```

**Verify:**
```bash
kubectl get pods -n python-app
kubectl get svc -n python-app
```

**Access:**
```bash
kubectl port-forward -n python-app svc/python-app 8080:8080
```

### 4. Kubernetes (Manifests)

Deploy using raw Kubernetes manifests.

**Deploy:**
```bash
kubectl apply -f k8s/
```

**Verify:**
```bash
kubectl get deployment,service,ingress
```

### 5. ArgoCD (GitOps)

Automated deployment via ArgoCD.

**Prerequisites:**
- ArgoCD installed in cluster
- GitHub repository access configured

**Deploy:**
```bash
kubectl apply -f argocd-ULP/template/python-app.yaml
```

**Monitor:**
```bash
kubectl get application python-app -n argocd
argocd app get python-app
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `FLASK_APP` | `app.py` | Flask application entry point |
| `FLASK_ENV` | `production` | Environment mode |
| `FLASK_RUN_HOST` | `0.0.0.0` | Bind to all interfaces |
| `FLASK_RUN_PORT` | `8080` | Application port |

### Kubernetes Resources

Default resource limits (configurable in Helm values):

- **Memory**: 64Mi request, 128Mi limit
- **CPU**: 50m request, 100m limit
- **Replicas**: 1

### Helm Values

Key values in `helm/flask-app-chart/values.yaml`:

```yaml
replicaCount: 1
image:
  repository: python-app
  tag: latest
service:
  type: ClusterIP
  port: 8080
```

## Health Checks

The application provides a `/health` endpoint for Kubernetes liveness and readiness probes:

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

## Scaling

### Horizontal Scaling

```bash
# Scale using kubectl
kubectl scale deployment python-app --replicas=3 -n python-app

# Or update Helm values
helm upgrade python-app . --set replicaCount=3
```

### Auto-scaling

Configure HorizontalPodAutoscaler:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: python-app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: python-app
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## Monitoring

### Logs

```bash
# View pod logs
kubectl logs -n python-app deployment/python-app

# Follow logs
kubectl logs -f -n python-app deployment/python-app
```

### Metrics

The application exposes standard Flask metrics. Integrate with Prometheus for monitoring.

## Rollback

### Helm Rollback

```bash
# List releases
helm list -n python-app

# Rollback to previous version
helm rollback python-app -n python-app
```

### ArgoCD Rollback

```bash
# Rollback via ArgoCD CLI
argocd app rollback python-app

# Or via kubectl
kubectl patch application python-app -n argocd \
  -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"<previous-revision>"}}}'
```

## Production Checklist

- [ ] Configure resource limits appropriately
- [ ] Set up monitoring and alerting
- [ ] Configure ingress with TLS
- [ ] Set up log aggregation
- [ ] Configure auto-scaling
- [ ] Set up backup and disaster recovery
- [ ] Review security policies
- [ ] Configure network policies

