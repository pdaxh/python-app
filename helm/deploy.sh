#!/bin/bash

set -e

CHART_NAME="flask-app"
RELEASE_NAME="flask-app-$(date +%s)"
NAMESPACE="tutorial"

echo "🚀 Flask App Helm Deployment Script"
echo "=================================="

# Function to show usage
show_usage() {
    echo "Usage: $0 [install|upgrade|uninstall|status|logs|test]"
    echo ""
    echo "Commands:"
    echo "  install   - Install the Flask app chart"
    echo "  upgrade   - Upgrade existing installation"
    echo "  uninstall - Remove the Flask app"
    echo "  status    - Show deployment status"
    echo "  logs      - Show application logs"
    echo "  test      - Test the deployed endpoints"
    echo ""
}

# Function to install the chart
install_chart() {
    echo "📦 Installing Flask app chart..."
    helm install $RELEASE_NAME ./flask-app-chart \
        --namespace $NAMESPACE \
        --create-namespace \
        --wait \
        --timeout 5m
    
    echo "✅ Installation complete!"
    echo "🔍 Check status with: $0 status"
    echo "🧪 Test endpoints with: $0 test"
}

# Function to upgrade the chart
upgrade_chart() {
    echo "🔄 Upgrading Flask app chart..."
    helm upgrade $RELEASE_NAME ./flask-app-chart \
        --namespace $NAMESPACE \
        --wait \
        --timeout 5m
    
    echo "✅ Upgrade complete!"
}

# Function to uninstall the chart
uninstall_chart() {
    echo "🗑️  Uninstalling Flask app..."
    helm uninstall $RELEASE_NAME --namespace $NAMESPACE
    
    echo "✅ Uninstallation complete!"
}

# Function to show status
show_status() {
    echo "📊 Deployment Status:"
    echo "====================="
    
    echo ""
    echo "🔍 Helm Release:"
    helm list --namespace $NAMESPACE | grep $RELEASE_NAME || echo "No release found"
    
    echo ""
    echo "🐳 Kubernetes Resources:"
    kubectl get deployment,service,ingress -l app.kubernetes.io/instance=$RELEASE_NAME 2>/dev/null || echo "No resources found"
    
    echo ""
    echo "📝 Pods:"
    kubectl get pods -l app.kubernetes.io/instance=$RELEASE_NAME 2>/dev/null || echo "No pods found"
}

# Function to show logs
show_logs() {
    echo "📝 Application Logs:"
    echo "===================="
    
    POD_NAME=$(kubectl get pods -l app.kubernetes.io/instance=$RELEASE_NAME -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    
    if [ -n "$POD_NAME" ]; then
        kubectl logs $POD_NAME --tail=50
    else
        echo "No pods found for release $RELEASE_NAME"
    fi
}

# Function to test endpoints
test_endpoints() {
    echo "🧪 Testing Endpoints:"
    echo "===================="
    
    # Auto-detect release name if not set
    if [ -z "$RELEASE_NAME" ]; then
        RELEASE_NAME=$(helm list -n $NAMESPACE --short | grep flask-app | head -1)
        if [ -z "$RELEASE_NAME" ]; then
            echo "❌ No Flask app release found in namespace $NAMESPACE"
            echo "💡 Try running: make helm-install"
            return 1
        fi
        echo "🔍 Auto-detected release: $RELEASE_NAME"
    fi
    
    # Check if Ingress is available
    INGRESS_IP=$(kubectl get ingress -l app.kubernetes.io/instance=$RELEASE_NAME -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    
    if [ -n "$INGRESS_IP" ]; then
        echo "🌐 Testing with Ingress IP: $INGRESS_IP"
        curl -s -H "Host: flask-app.local" "http://$INGRESS_IP/" | jq . 2>/dev/null || curl -s -H "Host: flask-app.local" "http://$INGRESS_IP/"
    else
        echo "🔌 Ingress not ready for external IP (normal for minikube)."
        echo ""
        echo "💡 For local testing, run this in another terminal:"
        echo "   kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80"
        echo ""
        echo "Then test with:"
        echo "   curl -H 'Host: flask-app.local' http://localhost:8080/"
        echo "   curl -H 'Host: flask-app.local' http://localhost:8080/datetime"
        echo "   curl -H 'Host: flask-app.local' http://localhost:8080/time"
        echo "   curl -H 'Host: flask-app.local' http://localhost:8080/date"
        echo ""
        echo "✅ Your Flask app is running and ready for testing!"
    fi
}

# Main script logic
case "${1:-}" in
    install)
        install_chart
        ;;
    upgrade)
        upgrade_chart
        ;;
    uninstall)
        uninstall_chart
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    test)
        test_endpoints
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
