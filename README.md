## Synopsis

This is a minimal non-trivial working example to boot up a
tensorflow-haskell project.

Type:

    $ make

and it should print the R-squared of a linear model computed by the
gradient-descent algorithm.

The above command is synonymous to:

    $ IMAGE_NAME=tensorflow-haskell-minimal-example:v0
    $ docker build -t $IMAGE_NAME docker
	$ stack --docker --docker-image=$IMAGE_NAME setup
	$ stack --docker --docker-image=$IMAGE_NAME build --exec linreg

See docker/Dockerfile, tensorflow-minimal-example.cabal, and
stack.yaml to adapt to your own project.
