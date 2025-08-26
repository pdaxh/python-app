.PHONY: build deploy clean test helm-install helm-upgrade helm-uninstall helm-status helm-logs helm-test

build:
	@echo "Building Docker image..."
	docker build -t danielaxhammar/flask-app:v2 Docker/

deploy:
	@echo "Deploying to Kubernetes..."
	kubectl apply -f k8s/
	kubectl wait --for=condition=available --timeout=60s deployment/flask-app

clean:
	@echo "Cleaning up..."
	kubectl delete -f k8s/ || true

test:
	@echo "Testing endpoints..."
	curl -H "Host: flask-app.local" http://127.0.0.1/
	curl -H "Host: flask-app.local" http://127.0.0.1/datetime

# Helm commands
helm-install:
	@echo "Installing Flask app with Helm in tutorial namespace..."
	cd helm && ./deploy.sh install

helm-upgrade:
	@echo "Upgrading Flask app with Helm in tutorial namespace..."
	cd helm && ./deploy.sh upgrade

helm-uninstall:
	@echo "Uninstalling Flask app with Helm from tutorial namespace..."
	cd helm && ./deploy.sh uninstall

helm-status:
	@echo "Checking Helm deployment status..."
	cd helm && ./deploy.sh status

helm-logs:
	@echo "Showing application logs..."
	cd helm && ./deploy.sh logs

helm-test:
	@echo "Testing Helm deployed endpoints..."
	cd helm && ./deploy.sh test

help:
	@echo "Available commands:"
	@echo "  make build         - Build Docker image"
	@echo "  make deploy        - Deploy to Kubernetes (kubectl)"
	@echo "  make clean         - Clean up deployment (kubectl)"
	@echo "  make test          - Test endpoints"
	@echo ""
	@echo "Helm commands:"
	@echo "  make helm-install  - Install with Helm"
	@echo "  make helm-upgrade  - Upgrade with Helm"
	@echo "  make helm-uninstall- Uninstall with Helm"
	@echo "  make helm-status   - Check Helm status"
	@echo "  make helm-logs     - Show application logs"
	@echo "  make helm-test     - Test Helm deployment"
