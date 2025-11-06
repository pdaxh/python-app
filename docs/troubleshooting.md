# Troubleshooting

Common issues and solutions for the Python Flask App.

## Local Development Issues

### Application Won't Start

**Problem:** Flask app fails to start

**Solutions:**
```bash
# Check Python version
python --version  # Should be 3.11+

# Verify dependencies
pip install -r src/requirements.txt

# Check if port is already in use
lsof -i :8080

# Try a different port
export FLASK_RUN_PORT=3000
python src/app.py
```

### Import Errors

**Problem:** Module not found errors

**Solutions:**
```bash
# Install dependencies
cd src
pip install -r requirements.txt

# Or use virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

## Docker Issues

### Image Build Fails

**Problem:** Docker build errors

**Solutions:**
```bash
# Check Dockerfile syntax
docker build -t python-app:test -f Docker/Dockerfile .

# Check for syntax errors
docker build --no-cache -t python-app:test -f Docker/Dockerfile .

# Verify context
docker build -t python-app:test -f Docker/Dockerfile .
```

### Container Won't Start

**Problem:** Container exits immediately

**Solutions:**
```bash
# Check logs
docker logs <container-id>

# Run interactively
docker run -it python-app:latest /bin/sh

# Check if port is available
docker run -p 8080:8080 python-app:latest
```

### Port Already in Use

**Problem:** Port 8080 is already in use

**Solutions:**
```bash
# Find what's using the port
lsof -i :8080  # macOS/Linux
netstat -ano | findstr :8080  # Windows

# Use a different port
docker run -p 3000:8080 python-app:latest
```

## Kubernetes Issues

### Pods Not Starting

**Problem:** Pods stuck in Pending or CrashLoopBackOff

**Solutions:**
```bash
# Check pod status
kubectl get pods -n python-app

# Describe pod for details
kubectl describe pod <pod-name> -n python-app

# Check logs
kubectl logs <pod-name> -n python-app

# Check events
kubectl get events -n python-app --sort-by='.lastTimestamp'
```

### Service Not Accessible

**Problem:** Cannot access service via port-forward

**Solutions:**
```bash
# Verify service exists
kubectl get svc -n python-app

# Check service endpoints
kubectl get endpoints -n python-app

# Verify pod is running
kubectl get pods -n python-app

# Try port-forward again
kubectl port-forward -n python-app svc/python-app 8080:8080
```

### Image Pull Errors

**Problem:** Cannot pull container image

**Solutions:**
```bash
# Check image name and tag
kubectl describe deployment python-app -n python-app

# Verify image exists
docker images | grep python-app

# Check image pull secrets
kubectl get secrets -n python-app

# For local images (minikube)
eval $(minikube docker-env)
docker build -t python-app:latest -f Docker/Dockerfile .
```

### Health Check Failures

**Problem:** Pods failing health checks

**Solutions:**
```bash
# Test health endpoint manually
kubectl exec -it <pod-name> -n python-app -- curl http://localhost:8080/health

# Check probe configuration
kubectl get deployment python-app -n python-app -o yaml | grep -A 10 probe

# Adjust probe timing if needed
# Edit deployment and increase initialDelaySeconds
```

## ArgoCD Issues

### Application Not Syncing

**Problem:** ArgoCD application shows OutOfSync

**Solutions:**
```bash
# Check application status
kubectl get application python-app -n argocd

# Describe application
kubectl describe application python-app -n argocd

# Check repository credentials
kubectl get secrets -n argocd | grep repo

# Manually trigger sync
argocd app sync python-app

# Or via kubectl
kubectl patch application python-app -n argocd \
  -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"syncStrategy":{"hook":{}}}}}'
```

### Repository Access Denied

**Problem:** ArgoCD cannot access GitHub repository

**Solutions:**
```bash
# Verify repository URL
kubectl get application python-app -n argocd -o yaml | grep repoURL

# Check repository credentials
kubectl get secret <repo-secret> -n argocd -o yaml

# Add/update repository secret
kubectl create secret generic github-credentials \
  --from-literal=type=git \
  --from-literal=url=https://github.com \
  --from-literal=username=<username> \
  --from-literal=password=<token> \
  -n argocd

kubectl annotate secret github-credentials -n argocd \
  argocd.argoproj.io/secret-type=repository
```

## Backstage Issues

### Component Not Showing in Catalog

**Problem:** Python app doesn't appear in Backstage catalog

**Solutions:**
```bash
# Check catalog location is configured
# Verify in app-config.local.yaml

# Check Backstage logs
docker compose -f docker-compose-simple.yml logs backstage | grep -i catalog

# Verify GitHub token is set
docker compose -f docker-compose-simple.yml exec backstage env | grep GITHUB_TOKEN

# Restart Backstage
docker compose -f docker-compose-simple.yml restart backstage
```

### TechDocs Not Rendering

**Problem:** Documentation not showing in Backstage

**Solutions:**
```bash
# Verify TechDocs annotation
# Should have: backstage.io/techdocs-ref: dir:.

# Check mkdocs.yml exists
ls -la docs/mkdocs.yml

# Verify TechDocs is enabled in Backstage config
# Check app-config.local.yaml for techdocs section

# Check Backstage logs
docker compose -f docker-compose-simple.yml logs backstage | grep -i techdocs
```

## Performance Issues

### Slow Response Times

**Problem:** API responses are slow

**Solutions:**
- Check resource limits in Kubernetes
- Verify sufficient CPU/memory allocation
- Check for network issues
- Review application logs for errors
- Consider horizontal scaling

### High Memory Usage

**Problem:** Application using too much memory

**Solutions:**
```bash
# Check current usage
kubectl top pod -n python-app

# Adjust resource limits in Helm values or deployment
# Increase memory limit if needed
```

## Getting Help

If you encounter issues not covered here:

1. **Check Logs**: Always start with application and system logs
2. **Review Documentation**: Check other docs in this folder
3. **GitHub Issues**: Report issues on [GitHub](https://github.com/pdaxh/python-app/issues)
4. **Team Support**: Contact the ULP Platform Team

## Debug Commands Reference

```bash
# Application logs
kubectl logs -n python-app deployment/python-app -f

# Pod status
kubectl get pods -n python-app -o wide

# Service endpoints
kubectl get endpoints -n python-app

# Events
kubectl get events -n python-app --sort-by='.lastTimestamp'

# Resource usage
kubectl top pod -n python-app

# Describe resources
kubectl describe deployment python-app -n python-app
kubectl describe service python-app -n python-app
```

