
IMAGE_REPO=ternau
IMAGE_NAME=resource-server
IMAGE_TAG=latest

IMAGE=$(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)


.PHONY: build test test-cov doc doc-live

build:
	rm -fr $(CURDIR)/dist/*.whl
	docker run --rm -it -v $(CURDIR):/workspace -w /workspace python:3.8 python setup.py bdist_wheel
	docker build -t $(IMAGE) .

test:
	docker run --rm -it \
	  -v $(CURDIR):/workspace \
	  -w /workspace \
	  -u root \
	  --entrypoint ./ci-scripts/run-tests.sh \
	  $(IMAGE)

test-cov:
	docker run --rm -it \
	  -v $(CURDIR):/workspace \
	  -w /workspace \
	  -u root \
	  --entrypoint ./ci-scripts/run-tests.sh \
	  $(IMAGE) \
	  --cov=resource-server --cov-report=html

doc:
	docker run --rm -it \
	  -v $(CURDIR):/workspace \
	  -w /workspace \
	  -u root \
	  --entrypoint ./ci-scripts/run-docs.sh \
	  $(IMAGE) \
	  html

doc-live:
	docker run --rm -it \
	  -p 8000:8000 \
	  -v $(CURDIR):/workspace \
	  -w /workspace \
	  -u root \
	  --entrypoint ./ci-scripts/run-docs.sh \
	  $(IMAGE) \
	  live
