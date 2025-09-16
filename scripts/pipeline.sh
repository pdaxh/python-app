#!/bin/bash

# Python App Pipeline Script
# This script demonstrates a complete CI/CD pipeline for the Python Flask app

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="python-app-pipeline"
NAMESPACE="daaxh25-dev"
GIT_REPO="https://github.com/pdaxh/python-app.git"
GIT_BRANCH="main"

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

# Step 1: Build the application
build_app() {
    print_header "Building Application"
    
    print_info "Starting build from Git repository..."
    oc start-build $APP_NAME --wait --follow
    
    if [ $? -eq 0 ]; then
        print_success "Build completed successfully"
    else
        print_error "Build failed"
        exit 1
    fi
}

# Step 2: Deploy the application
deploy_app() {
    print_header "Deploying Application"
    
    print_info "Updating deployment with new image..."
    oc rollout restart deployment/$APP_NAME-deploy
    
    print_info "Waiting for deployment to complete..."
    oc rollout status deployment/$APP_NAME-deploy --timeout=300s
    
    if [ $? -eq 0 ]; then
        print_success "Deployment completed successfully"
    else
        print_error "Deployment failed"
        exit 1
    fi
}

# Step 3: Test the application
test_app() {
    print_header "Testing Application"
    
    # Get the route URL
    ROUTE_URL=$(oc get route $APP_NAME-deploy -o jsonpath='{.spec.host}')
    
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
    
    # Test datetime endpoint
    if curl -s -f "http://$ROUTE_URL/datetime" > /dev/null; then
        print_success "Datetime endpoint test passed"
    else
        print_error "Datetime endpoint test failed"
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

# Step 4: Show application status
show_status() {
    print_header "Application Status"
    
    echo "Deployment Status:"
    oc get deployment $APP_NAME-deploy
    
    echo ""
    echo "Pod Status:"
    oc get pods -l app=$APP_NAME-deploy
    
    echo ""
    echo "Service Status:"
    oc get service $APP_NAME-deploy
    
    echo ""
    echo "Route Status:"
    oc get route $APP_NAME-deploy
    
    echo ""
    ROUTE_URL=$(oc get route $APP_NAME-deploy -o jsonpath='{.spec.host}')
    print_success "Application is available at: http://$ROUTE_URL"
}

# Step 5: Cleanup (optional)
cleanup() {
    print_header "Cleaning Up"
    
    read -p "Do you want to delete the pipeline resources? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Deleting pipeline resources..."
        oc delete all -l app=$APP_NAME-deploy
        oc delete buildconfig $APP_NAME
        print_success "Cleanup completed"
    else
        print_info "Cleanup skipped"
    fi
}

# Main pipeline execution
main() {
    print_header "Python App Pipeline"
    print_info "Starting pipeline for $APP_NAME"
    
    # Check if we're logged into OpenShift
    if ! oc whoami > /dev/null 2>&1; then
        print_error "Not logged into OpenShift. Please run 'oc login' first."
        exit 1
    fi
    
    # Check if namespace exists
    if ! oc get namespace $NAMESPACE > /dev/null 2>&1; then
        print_error "Namespace $NAMESPACE does not exist"
        exit 1
    fi
    
    # Execute pipeline steps
    build_app
    deploy_app
    test_app
    show_status
    
    print_success "Pipeline completed successfully!"
}

# Handle command line arguments
case "${1:-}" in
    "build")
        build_app
        ;;
    "deploy")
        deploy_app
        ;;
    "test")
        test_app
        ;;
    "status")
        show_status
        ;;
    "cleanup")
        cleanup
        ;;
    *)
        main
        ;;
esac
