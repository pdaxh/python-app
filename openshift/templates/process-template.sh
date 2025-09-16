#!/bin/bash

# OpenShift Template Processing Script
# This script processes the Python app template with custom parameters

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
APPLICATION_NAME="python-app"
NAMESPACE="daaxh25-dev"
IMAGE_NAME="image-registry.openshift-image-registry.svc:5000/daaxh25-dev/python-app-pipeline:latest"
REPLICAS="1"
CPU_REQUEST="50m"
CPU_LIMIT="100m"
MEMORY_REQUEST="64Mi"
MEMORY_LIMIT="128Mi"
FLASK_APP="app.py"
FLASK_ENV="production"
FLASK_RUN_HOST="0.0.0.0"
FLASK_RUN_PORT="8080"
LOG_LEVEL="INFO"
ROUTE_HOST=""
ROUTE_TLS_TERMINATION="edge"
HEALTH_CHECK_PATH="/health"
READINESS_CHECK_PATH="/health"
APP_VERSION="1.0.0"
APP_DESCRIPTION="Python Flask Web Application"

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

show_help() {
    cat << EOF
OpenShift Template Processing Script

Usage: $0 [OPTIONS] [COMMAND]

Commands:
  process    Process the template with parameters (default)
  deploy     Process and deploy the template
  delete     Delete resources created from template
  list       List available templates
  help       Show this help message

Options:
  -n, --name NAME              Application name (default: $APPLICATION_NAME)
  -s, --namespace NAMESPACE    Namespace (default: $NAMESPACE)
  -i, --image IMAGE            Image name (default: $IMAGE_NAME)
  -r, --replicas REPLICAS      Number of replicas (default: $REPLICAS)
  -c, --cpu-request CPU        CPU request (default: $CPU_REQUEST)
  -C, --cpu-limit CPU          CPU limit (default: $CPU_LIMIT)
  -m, --memory-request MEM     Memory request (default: $MEMORY_REQUEST)
  -M, --memory-limit MEM       Memory limit (default: $MEMORY_LIMIT)
  -e, --env ENV                Flask environment (default: $FLASK_ENV)
  -p, --port PORT              Flask port (default: $FLASK_RUN_PORT)
  -l, --log-level LEVEL        Log level (default: $LOG_LEVEL)
  -h, --host HOST              Route hostname (default: auto-generated)
  -t, --tls TERMINATION        TLS termination (default: $ROUTE_TLS_TERMINATION)
  -v, --version VERSION        App version (default: $APP_VERSION)
  -d, --description DESC       App description (default: $APP_DESCRIPTION)
  --dry-run                    Show what would be created without applying
  --help                       Show this help message

Examples:
  $0 deploy --name my-app --namespace my-namespace
  $0 process --replicas 3 --memory-limit 256Mi
  $0 delete --name my-app --namespace my-namespace
  $0 --dry-run --name test-app

EOF
}

# Parse command line arguments
COMMAND="process"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        process|deploy|delete|list|help)
            COMMAND="$1"
            shift
            ;;
        -n|--name)
            APPLICATION_NAME="$2"
            shift 2
            ;;
        -s|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -i|--image)
            IMAGE_NAME="$2"
            shift 2
            ;;
        -r|--replicas)
            REPLICAS="$2"
            shift 2
            ;;
        -c|--cpu-request)
            CPU_REQUEST="$2"
            shift 2
            ;;
        -C|--cpu-limit)
            CPU_LIMIT="$2"
            shift 2
            ;;
        -m|--memory-request)
            MEMORY_REQUEST="$2"
            shift 2
            ;;
        -M|--memory-limit)
            MEMORY_LIMIT="$2"
            shift 2
            ;;
        -e|--env)
            FLASK_ENV="$2"
            shift 2
            ;;
        -p|--port)
            FLASK_RUN_PORT="$2"
            shift 2
            ;;
        -l|--log-level)
            LOG_LEVEL="$2"
            shift 2
            ;;
        -h|--host)
            ROUTE_HOST="$2"
            shift 2
            ;;
        -t|--tls)
            ROUTE_TLS_TERMINATION="$2"
            shift 2
            ;;
        -v|--version)
            APP_VERSION="$2"
            shift 2
            ;;
        -d|--description)
            APP_DESCRIPTION="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check if oc is logged in
check_oc_login() {
    if ! oc whoami > /dev/null 2>&1; then
        print_error "Not logged into OpenShift. Please run 'oc login' first."
        exit 1
    fi
    print_info "Logged in as: $(oc whoami)"
}

# Process template
process_template() {
    print_header "Processing OpenShift Template"
    
    print_info "Template: python-app-template"
    print_info "Application: $APPLICATION_NAME"
    print_info "Namespace: $NAMESPACE"
    print_info "Image: $IMAGE_NAME"
    print_info "Replicas: $REPLICAS"
    print_info "Resources: ${CPU_REQUEST}/${CPU_LIMIT} CPU, ${MEMORY_REQUEST}/${MEMORY_LIMIT} Memory"
    
    if [ "$DRY_RUN" = true ]; then
        print_info "DRY RUN - Showing what would be created:"
        echo ""
        oc process -f python-app-template.yaml \
            -p APPLICATION_NAME="$APPLICATION_NAME" \
            -p NAMESPACE="$NAMESPACE" \
            -p IMAGE_NAME="$IMAGE_NAME" \
            -p REPLICAS="$REPLICAS" \
            -p CPU_REQUEST="$CPU_REQUEST" \
            -p CPU_LIMIT="$CPU_LIMIT" \
            -p MEMORY_REQUEST="$MEMORY_REQUEST" \
            -p MEMORY_LIMIT="$MEMORY_LIMIT" \
            -p FLASK_APP="$FLASK_APP" \
            -p FLASK_ENV="$FLASK_ENV" \
            -p FLASK_RUN_HOST="$FLASK_RUN_HOST" \
            -p FLASK_RUN_PORT="$FLASK_RUN_PORT" \
            -p LOG_LEVEL="$LOG_LEVEL" \
            -p ROUTE_HOST="$ROUTE_HOST" \
            -p ROUTE_TLS_TERMINATION="$ROUTE_TLS_TERMINATION" \
            -p HEALTH_CHECK_PATH="$HEALTH_CHECK_PATH" \
            -p READINESS_CHECK_PATH="$READINESS_CHECK_PATH" \
            -p APP_VERSION="$APP_VERSION" \
            -p APP_DESCRIPTION="$APP_DESCRIPTION"
    else
        oc process -f python-app-template.yaml \
            -p APPLICATION_NAME="$APPLICATION_NAME" \
            -p NAMESPACE="$NAMESPACE" \
            -p IMAGE_NAME="$IMAGE_NAME" \
            -p REPLICAS="$REPLICAS" \
            -p CPU_REQUEST="$CPU_REQUEST" \
            -p CPU_LIMIT="$CPU_LIMIT" \
            -p MEMORY_REQUEST="$MEMORY_REQUEST" \
            -p MEMORY_LIMIT="$MEMORY_LIMIT" \
            -p FLASK_APP="$FLASK_APP" \
            -p FLASK_RUN_HOST="$FLASK_RUN_HOST" \
            -p FLASK_RUN_PORT="$FLASK_RUN_PORT" \
            -p LOG_LEVEL="$LOG_LEVEL" \
            -p ROUTE_HOST="$ROUTE_HOST" \
            -p ROUTE_TLS_TERMINATION="$ROUTE_TLS_TERMINATION" \
            -p HEALTH_CHECK_PATH="$HEALTH_CHECK_PATH" \
            -p READINESS_CHECK_PATH="$READINESS_CHECK_PATH" \
            -p APP_VERSION="$APP_VERSION" \
            -p APP_DESCRIPTION="$APP_DESCRIPTION"
    fi
}

# Deploy template
deploy_template() {
    print_header "Deploying from Template"
    
    check_oc_login
    
    print_info "Creating namespace if it doesn't exist..."
    oc create namespace "$NAMESPACE" --dry-run=client -o yaml | oc apply -f -
    
    print_info "Processing and applying template..."
    oc process -f python-app-template.yaml \
        -p APPLICATION_NAME="$APPLICATION_NAME" \
        -p NAMESPACE="$NAMESPACE" \
        -p IMAGE_NAME="$IMAGE_NAME" \
        -p REPLICAS="$REPLICAS" \
        -p CPU_REQUEST="$CPU_REQUEST" \
        -p CPU_LIMIT="$CPU_LIMIT" \
        -p MEMORY_REQUEST="$MEMORY_REQUEST" \
        -p MEMORY_LIMIT="$MEMORY_LIMIT" \
        -p FLASK_APP="$FLASK_APP" \
        -p FLASK_ENV="$FLASK_ENV" \
        -p FLASK_RUN_HOST="$FLASK_RUN_HOST" \
        -p FLASK_RUN_PORT="$FLASK_RUN_PORT" \
        -p LOG_LEVEL="$LOG_LEVEL" \
        -p ROUTE_HOST="$ROUTE_HOST" \
        -p ROUTE_TLS_TERMINATION="$ROUTE_TLS_TERMINATION" \
        -p HEALTH_CHECK_PATH="$HEALTH_CHECK_PATH" \
        -p READINESS_CHECK_PATH="$READINESS_CHECK_PATH" \
        -p APP_VERSION="$APP_VERSION" \
        -p APP_DESCRIPTION="$APP_DESCRIPTION" | oc apply -f -
    
    print_success "Template deployed successfully!"
    
    print_info "Waiting for deployment to be ready..."
    oc rollout status deployment/"$APPLICATION_NAME" -n "$NAMESPACE" --timeout=300s
    
    print_info "Getting application URL..."
    ROUTE_URL=$(oc get route "$APPLICATION_NAME-route" -n "$NAMESPACE" -o jsonpath='{.spec.host}' 2>/dev/null || echo "No route found")
    if [ -n "$ROUTE_URL" ]; then
        print_success "Application deployed at: http://$ROUTE_URL"
    else
        print_info "No route found - check route configuration"
    fi
}

# Delete resources
delete_resources() {
    print_header "Deleting Resources"
    
    check_oc_login
    
    print_info "Deleting resources for application: $APPLICATION_NAME in namespace: $NAMESPACE"
    
    oc delete route "$APPLICATION_NAME-route" -n "$NAMESPACE" --ignore-not-found=true
    oc delete service "$APPLICATION_NAME" -n "$NAMESPACE" --ignore-not-found=true
    oc delete deployment "$APPLICATION_NAME" -n "$NAMESPACE" --ignore-not-found=true
    oc delete configmap "$APPLICATION_NAME-config" -n "$NAMESPACE" --ignore-not-found=true
    
    print_success "Resources deleted successfully!"
}

# List templates
list_templates() {
    print_header "Available Templates"
    
    print_info "Templates in current directory:"
    ls -la *.yaml 2>/dev/null || echo "No YAML files found"
    
    print_info "Templates in OpenShift:"
    oc get templates -n "$NAMESPACE" 2>/dev/null || echo "No templates found in namespace $NAMESPACE"
}

# Main execution
case "$COMMAND" in
    "process")
        process_template
        ;;
    "deploy")
        deploy_template
        ;;
    "delete")
        delete_resources
        ;;
    "list")
        list_templates
        ;;
    "help")
        show_help
        ;;
    *)
        print_error "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac
