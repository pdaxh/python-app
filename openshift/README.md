# OpenShift Infrastructure as Code

This directory contains all OpenShift configurations for the Python Flask application, following Infrastructure as Code (IaC) principles.

## 📁 Directory Structure

```
openshift/
├── configmaps/           # Configuration data
│   └── python-app-config.yaml
├── deployments/          # Application deployments
│   └── python-app-deployment.yaml
├── services/             # Service definitions
│   └── python-app-service.yaml
├── routes/               # Route definitions
│   └── python-app-route.yaml
├── pipelines/            # Tekton pipelines
│   └── python-app-pipeline.yaml
├── scripts/              # Deployment scripts
│   └── deploy.sh
├── kustomization.yaml    # Kustomize configuration
└── README.md            # This file
```

## 🚀 Quick Start

### Prerequisites

- OpenShift CLI (`oc`) installed and logged in
- Access to OpenShift cluster
- Python app built and available in image registry

### Deploy with Kustomize (Recommended)

```bash
# Deploy all resources
oc apply -k .

# Or use the deployment script
./scripts/deploy.sh deploy kustomize
```

### Deploy Individual Resources

```bash
# Deploy each resource individually
oc apply -f configmaps/python-app-config.yaml
oc apply -f deployments/python-app-deployment.yaml
oc apply -f services/python-app-service.yaml
oc apply -f routes/python-app-route.yaml
```

## 🔧 Configuration

### Environment Variables

Edit `configmaps/python-app-config.yaml` to modify environment variables:

```yaml
data:
  FLASK_APP: "app.py"
  FLASK_ENV: "production"
  FLASK_RUN_HOST: "0.0.0.0"
  FLASK_RUN_PORT: "8080"
  LOG_LEVEL: "INFO"
```

### Resource Limits

Modify `deployments/python-app-deployment.yaml` to adjust resource limits:

```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "50m"
  limits:
    memory: "128Mi"
    cpu: "100m"
```

### Route Configuration

Update `routes/python-app-route.yaml` for custom hostnames or SSL:

```yaml
spec:
  host: your-custom-hostname.com
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
```

## 🧪 Testing

### Test the Application

```bash
# Get the application URL
oc get route python-app-tekton-route -o jsonpath='{.spec.host}'

# Test endpoints
curl http://your-app-url/
curl http://your-app-url/health
curl http://your-app-url/datetime
```

### Run Tests

```bash
./scripts/deploy.sh test
```

## 📊 Monitoring

### Check Application Status

```bash
# View all resources
oc get all -l app=python-app-tekton

# Check pod logs
oc logs -l app=python-app-tekton

# Check deployment status
oc rollout status deployment/python-app-tekton
```

### Monitor with Script

```bash
./scripts/deploy.sh status
```

## 🔄 CI/CD Integration

### Tekton Pipeline

The pipeline is defined in `pipelines/python-app-pipeline.yaml` and includes:

1. **Fetch Repository**: Clone source code
2. **Build**: Build application with S2I
3. **Deploy**: Apply OpenShift resources

### GitHub Actions

The GitHub Actions workflow automatically deploys to OpenShift when changes are pushed to the main branch.

## 🧹 Cleanup

### Remove All Resources

```bash
# Using Kustomize
oc delete -k .

# Using script
./scripts/deploy.sh cleanup
```

### Remove Individual Resources

```bash
oc delete -f configmaps/python-app-config.yaml
oc delete -f deployments/python-app-deployment.yaml
oc delete -f services/python-app-service.yaml
oc delete -f routes/python-app-route.yaml
```

## 📝 Best Practices

1. **Version Control**: All configurations are stored in Git
2. **Environment Separation**: Use different namespaces for dev/staging/prod
3. **Resource Limits**: Always set appropriate CPU and memory limits
4. **Security**: Use non-root containers and security contexts
5. **Monitoring**: Include health checks and readiness probes
6. **Documentation**: Keep this README updated with changes

## 🔍 Troubleshooting

### Common Issues

1. **Image Pull Errors**: Check image registry access
2. **Resource Limits**: Adjust CPU/memory limits if pods are being killed
3. **Route Issues**: Verify hostname and DNS configuration
4. **Health Check Failures**: Check application logs and health endpoint

### Debug Commands

```bash
# Check pod status
oc describe pod <pod-name>

# View pod logs
oc logs <pod-name>

# Check service endpoints
oc get endpoints python-app-tekton

# Check route configuration
oc describe route python-app-tekton-route
```

## 📚 Additional Resources

- [OpenShift Documentation](https://docs.openshift.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Tekton Documentation](https://tekton.dev/docs/)
- [Kustomize Documentation](https://kustomize.io/)
