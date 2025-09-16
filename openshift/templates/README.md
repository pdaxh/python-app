# OpenShift Templates for Python Flask Application

This directory contains OpenShift Templates for deploying Python Flask applications with different configurations and use cases.

## 📁 Available Templates

### 1. **python-app-template.yaml** - Full Featured Template
Complete template with all parameters and features:
- ConfigMap with environment variables
- Deployment with resource limits and health checks
- Service with load balancing
- Route with TLS termination
- Comprehensive parameterization

**Use Case**: Production deployments with full control over all aspects

### 2. **python-app-simple.yaml** - Simple Template
Minimal template for quick deployments:
- Basic ConfigMap, Deployment, Service, and Route
- Minimal parameters
- Default resource settings

**Use Case**: Quick deployments and testing

### 3. **python-app-dev.yaml** - Development Template
Template optimized for development:
- Debug port exposed
- Development environment settings
- Debugger support with debugpy
- Hot reloading capabilities

**Use Case**: Development and debugging

## 🚀 Quick Start

### Using the Processing Script

The `process-template.sh` script provides an easy way to work with templates:

```bash
# Deploy with default settings
./process-template.sh deploy

# Deploy with custom parameters
./process-template.sh deploy --name my-app --namespace my-namespace --replicas 3

# Dry run to see what would be created
./process-template.sh process --dry-run --name test-app

# Delete resources
./process-template.sh delete --name my-app --namespace my-namespace
```

### Using OpenShift CLI

#### 1. Process and Deploy Template

```bash
# Full featured template
oc process -f python-app-template.yaml \
  -p APPLICATION_NAME=my-app \
  -p NAMESPACE=my-namespace \
  -p IMAGE_NAME=my-registry/my-app:latest \
  -p REPLICAS=2 | oc apply -f -

# Simple template
oc process -f python-app-simple.yaml \
  -p APPLICATION_NAME=my-app \
  -p NAMESPACE=my-namespace | oc apply -f -

# Development template
oc process -f python-app-dev.yaml \
  -p APPLICATION_NAME=my-app-dev \
  -p NAMESPACE=my-namespace | oc apply -f -
```

#### 2. Deploy from OpenShift Web Console

1. Go to OpenShift Web Console
2. Navigate to your project/namespace
3. Click "Add to Project" → "From Catalog"
4. Upload the template YAML file
5. Fill in the parameters
6. Click "Create"

## 📋 Template Parameters

### Common Parameters

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `APPLICATION_NAME` | Name of the application | `python-app` | Yes |
| `NAMESPACE` | Target namespace | `daaxh25-dev` | Yes |
| `IMAGE_NAME` | Container image name | `image-registry...` | Yes |

### Full Template Parameters

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `REPLICAS` | Number of replicas | `1` | Yes |
| `CPU_REQUEST` | CPU request | `50m` | Yes |
| `CPU_LIMIT` | CPU limit | `100m` | Yes |
| `MEMORY_REQUEST` | Memory request | `64Mi` | Yes |
| `MEMORY_LIMIT` | Memory limit | `128Mi` | Yes |
| `FLASK_APP` | Flask app file | `app.py` | Yes |
| `FLASK_ENV` | Flask environment | `production` | Yes |
| `FLASK_RUN_HOST` | Flask host | `0.0.0.0` | Yes |
| `FLASK_RUN_PORT` | Flask port | `8080` | Yes |
| `LOG_LEVEL` | Log level | `INFO` | Yes |
| `ROUTE_HOST` | Route hostname | `""` (auto) | No |
| `ROUTE_TLS_TERMINATION` | TLS termination | `edge` | No |
| `HEALTH_CHECK_PATH` | Health check path | `/health` | Yes |
| `READINESS_CHECK_PATH` | Readiness check path | `/health` | Yes |
| `APP_VERSION` | Application version | `1.0.0` | Yes |
| `APP_DESCRIPTION` | App description | `Python Flask Web Application` | Yes |

### Development Template Parameters

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `DEBUG_PORT` | Debug port | `5678` | Yes |

## 🔧 Customization

### Adding New Parameters

1. Add parameter definition to the template:
```yaml
parameters:
  - name: NEW_PARAMETER
    displayName: "New Parameter"
    description: "Description of the parameter"
    value: "default-value"
    required: true
```

2. Use the parameter in objects:
```yaml
objects:
  - apiVersion: v1
    kind: ConfigMap
    metadata:
      name: "${APPLICATION_NAME}-config"
    data:
      NEW_CONFIG: "${NEW_PARAMETER}"
```

### Adding New Objects

Add new OpenShift resources to the `objects` section:

```yaml
objects:
  - apiVersion: v1
    kind: Secret
    metadata:
      name: "${APPLICATION_NAME}-secret"
    type: Opaque
    data:
      secret-key: "${SECRET_VALUE}"
```

## 🧪 Testing Templates

### Dry Run

```bash
# See what would be created
oc process -f python-app-template.yaml \
  -p APPLICATION_NAME=test-app | oc apply --dry-run=client -f -
```

### Template Validation

```bash
# Validate template syntax
oc process -f python-app-template.yaml --parameters

# Test with specific parameters
oc process -f python-app-template.yaml \
  -p APPLICATION_NAME=test-app \
  -p NAMESPACE=test-namespace
```

## 📊 Monitoring and Management

### Check Template Status

```bash
# List templates in namespace
oc get templates -n daaxh25-dev

# Describe template
oc describe template python-app-template -n daaxh25-dev
```

### Monitor Deployed Resources

```bash
# Check all resources created from template
oc get all -l template=python-app-template

# Check specific application
oc get all -l app=my-app
```

## 🧹 Cleanup

### Delete Resources

```bash
# Delete by template label
oc delete all -l template=python-app-template

# Delete specific application
oc delete all -l app=my-app

# Delete using script
./process-template.sh delete --name my-app --namespace my-namespace
```

## 📚 Best Practices

1. **Parameter Validation**: Always validate required parameters before processing
2. **Resource Naming**: Use consistent naming conventions with parameters
3. **Labels**: Apply proper labels for resource management
4. **Security**: Use appropriate security contexts and resource limits
5. **Documentation**: Keep parameter descriptions up to date
6. **Testing**: Test templates in development before production use

## 🔍 Troubleshooting

### Common Issues

1. **Parameter Not Found**: Check parameter names match exactly
2. **Resource Conflicts**: Ensure unique names across namespaces
3. **Image Pull Errors**: Verify image name and registry access
4. **Template Processing Errors**: Check YAML syntax and indentation

### Debug Commands

```bash
# Check template processing
oc process -f python-app-template.yaml --parameters

# Validate YAML syntax
oc process -f python-app-template.yaml --dry-run=client

# Check resource status
oc get events --sort-by=.metadata.creationTimestamp
```

## 📖 Additional Resources

- [OpenShift Templates Documentation](https://docs.openshift.com/container-platform/latest/openshift_images/using-templates.html)
- [Kubernetes Templates](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Flask Documentation](https://flask.palletsprojects.com/)
