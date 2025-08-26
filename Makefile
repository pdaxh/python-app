.PHONY: build deploy clean test

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

help:
	@echo "Available commands:"
	@echo "  make build   - Build Docker image"
	@echo "  make deploy  - Deploy to Kubernetes"
	@echo "  make clean   - Clean up deployment"
	@echo "  make test    - Test endpoints"
