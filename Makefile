IMAGE_NAME=tensorflow-haskell-minimal-example:v0

bootstrap:
	docker build -t $(IMAGE_NAME) docker && \
	stack --docker --docker-image=$(IMAGE_NAME) setup && \
	stack --docker --docker-image=$(IMAGE_NAME) build --exec linreg
