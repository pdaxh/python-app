#!/bin/bash
echo "Deploying Flask app to Kubernetes..."

# Apply Kubernetes manifests
kubectl apply -f k8s/

# Wait for deployment to be ready
kubectl wait --for=condition=available --timeout=60s deployment/flask-app

echo "Deployment complete!"
echo "Add to /etc/hosts: 127.0.0.1 flask-app.local"
echo "Test with: curl -H 'Host: flask-app.local' http://127.0.0.1/"
