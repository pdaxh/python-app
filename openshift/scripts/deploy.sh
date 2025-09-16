#!/bin/bash

# OpenShift Deployment Script
# This script deploys the Python app using Infrastructure as Code

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="daaxh25-dev"
APP_NAME="python-app-tekton"

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

print_info() {
    echo -e "${YELLOW}INFO: $1${NC}"
}

# Check if oc is logged in
check_oc_login() {
    if ! oc whoami > /dev/null 2>&1; then
        print_error "Not logged into OpenShift. Please run 'oc login' first."
        exit 1
    fi
    print_info "Logged in as: $(oc whoami)"
}

# Deploy using Kustomize
deploy_with_kustomize() {
    print_header "Deploying with Kustomize"
    
    print_info "Applying Kustomization..."
    oc apply -k .
    
    if [ $? -eq 0 ]; then
        print_success "Kustomization applied successfully"
    else
        print_error "Kustomization failed"
        exit 1
    fi
}

# Deploy individual resources
deploy_individual() {
    print_header "Deploying Individual Resources"
    
    print_info "Applying ConfigMap..."
    oc apply -f configmaps/python-app-config.yaml
    
    print_info "Applying Deployment..."
    oc apply -f deployments/python-app-deployment.yaml
    
    print_info "Applying Service..."
    oc apply -f services/python-app-service.yaml
    
    print_info "Applying Route..."
    oc apply -f routes/python-app-route.yaml
    
    print_success "All resources applied successfully"
}

# Wait for deployment
wait_for_deployment() {
    print_header "Waiting for Deployment"
    
    print_info "Waiting for deployment to be ready..."
    oc rollout status deployment/$APP_NAME -n $NAMESPACE --timeout=300s
    
    if [ $? -eq 0 ]; then
        print_success "Deployment is ready"
    else
        print_error "Deployment failed or timed out"
        exit 1
    fi
}

# Show application status
show_status() {
    print_header "Application Status"
    
    echo "Deployment Status:"
    oc get deployment $APP_NAME -n $NAMESPACE
    
    echo ""
    echo "Pod Status:"
    oc get pods -l app=$APP_NAME -n $NAMESPACE
    
    echo ""
    echo "Service Status:"
    oc get service $APP_NAME -n $NAMESPACE
    
    echo ""
    echo "Route Status:"
    oc get route $APP_NAME-route -n $NAMESPACE
    
    echo ""
    ROUTE_URL=$(oc get route $APP_NAME-route -n $NAMESPACE -o jsonpath='{.spec.host}')
    print_success "Application is available at: http://$ROUTE_URL"
}

# Test application
test_application() {
    print_header "Testing Application"
    
    ROUTE_URL=$(oc get route $APP_NAME-route -n $NAMESPACE -o jsonpath='{.spec.host}')
    
    if [ -z "$ROUTE_URL" ]; then
        print_error "Could not get route URL"
        exit 1
    fi
    
    print_info "Testing application at: http://$ROUTE_URL"
    
    # Test basic endpoint
    if curl -s -f "http://$ROUTE_URL/" > /dev/null; then
        print_success "Basic endpoint test passed"
    else
        print_error "Basic endpoint test failed"
        exit 1
    fi
    
    # Test health endpoint
    if curl -s -f "http://$ROUTE_URL/health" > /dev/null; then
        print_success "Health endpoint test passed"
    else
        print_error "Health endpoint test failed"
        exit 1
    fi
}

# Cleanup
cleanup() {
    print_header "Cleaning Up"
    
    read -p "Do you want to delete all resources? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Deleting all resources..."
        oc delete -k .
        print_success "Cleanup completed"
    else
        print_info "Cleanup skipped"
    fi
}

# Main execution
main() {
    print_header "Python App OpenShift Deployment"
    
    check_oc_login
    
    case "${1:-kustomize}" in
        "kustomize")
            deploy_with_kustomize
            ;;
        "individual")
            deploy_individual
            ;;
        *)
            print_error "Unknown deployment method: $1"
            print_info "Usage: $0 [kustomize|individual]"
            exit 1
            ;;
    esac
    
    wait_for_deployment
    show_status
    test_application
    
    print_success "Deployment completed successfully!"
}

# Handle command line arguments
case "${1:-}" in
    "deploy")
        main "${2:-kustomize}"
        ;;
    "status")
        show_status
        ;;
    "test")
        test_application
        ;;
    "cleanup")
        cleanup
        ;;
    *)
        main "${1:-kustomize}"
        ;;
esac
