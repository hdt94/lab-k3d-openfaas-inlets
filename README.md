# Lab k3d + OpenFaaS + Inlets

Setup OpenFaaS in a single node running on a k3s cluster managed with k3d and tunneled to a Digital Ocean droplet using Inlets to deploy two functions for encoding-decoding JSON Web Tokens JWTs at following HTTP endpoints:
```
/function/encode-jwt-hs256
/function/decode-jwt-hs256
```
Both computing environment to run OpenFaaS and development environment to deploy functions are installed directly in local machine.

**Warning: No SSL/TLS is used**

This lab has been correctly tested on Ubuntu 18 Bionic. Installers of tools are intended to be cross-platform so no major issue should appear with macOS. Windows users may find troubles but using Git Bash is encouraged.

`inlets-operator` is not used because of problems at running default tunneling of services on k3s.

## Prerequisites

1. Docker installed: [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/)

2. Install `k3d` + `kubectl` + `arkade` + `inlets` + `inletsctl` for computing:
	```bash
	$ sudo chmod +x provisions/prod-env.sh && sudo provisions/prod-env.sh
	```
	
3. Install `faas-cli` for development:
	```bash
	$ sudo chmod +x provisions/dev-env.sh && sudo provisions/dev-env.sh
	```

4. Digital Ocean token stored in text file: [https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/](https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/)

	```bash
	$ export $TOKEN= # Paste your token
	$ touch ~/token_do
	$ echo $TOKEN > ~/token_do
	```

## Up and running

Note: some configurations and pods may take a while before ready so be sure to watch asciinema with `watch` commands at [https://asciinema.org/a/341395](https://asciinema.org/a/341395)

### Computing environment setup

Note: you must `export KUBECONFIG` in every session; optionally can append to ~/.bash_profile

Setup OpenFaaS in a k3s cluster with k3d:
```bash
$ k3d create
$ export KUBECONFIG="$(k3d get-kubeconfig --name='k3s-default')"
$ arkade install openfaas --load-balancer
$ echo "PASSWORD=$(kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode)"
```

Create and provision droplet:
```bash
$ inletsctl create --provider digitalocean \
	--region nyc1 \
	--access-token-file ~/token_do
```

Copy `inlets client --remote VALUE --token VALUE --upstream $UPSTREAM` command from previous step.

Connect OpenFaaS with droplet:
```bash
$ kubectl get svc gateway-external -n openfaas
$ export UPSTREAM= # Copy EXTERNAL-IP at port 8080
$ inlets client --remote "ws://161.35.50.52:8080" \
	--token "50K7z5DszCiGguibgxl7k4nToBBNcziPNtCKiYOcK5BCeMBfZNAvaPpsG5yU3Jq3" \
	--upstream $UPSTREAM
```

### Development environment setup

Login and deploy functions:
```bash
$ export OPENFAAS_PASSWORD= # Copy value of $PASSWORD in computing environment setup
$ export OPENFAAS_URL= # Copy value of $UPSTREAM in computing environment setup
$ faas-cli login --username admin --password $OPENFAAS_PASSWORD
$ faas-cli template pull
$ faas-cli deploy -f functions.yml
$ faas-cli ls
```

## Usage with `curl`

Notes: `$CLOUD_URL` is copied from computing environment setup.

Define a secret to sign JWT:
```bash
$ export CLOUD_URL= # Copy public IP of droplet in computing environment setup
$ export PAYLOAD="{ \"name\": \"hdt\", \"iat\": 50 }"
$ export SECRET=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32})
```

Encode a payload into a JWT:
```bash
$ export JWT=$(curl -s "$CLOUD_URL/function/encode-jwt-hs256" -d "{ \"payload\": ${PAYLOAD}, \"secret\": \"$SECRET\" }")
$ echo "JWT=$JWT"
```

Decode data from a JWT:
```bash
$ echo "PAYLOAD=$(curl -s "$CLOUD_URL/function/decode-jwt-hs256" -d "{ \"encoded\": \"$JWT\", \"secret\": \"$SECRET\" }")"
```

## Up new functions

Notes:
- you must modify the prefix of images in `functions.yml` to your `$DOCKER_ID`.
- `$DOCKER_ID` and `$DOCKER_PASSWORD` are up to you.

Login into Docker:
```bash
$ docker login --username $DOCKER_ID --password $DOCKER_PASSWORD
```

Create and up a new function:
```bash
$ export FUNCTION=encode-jwt-hs256
$ faas-cli new $FUNCTION -q --lang python3 -a functions.yml --handler src/functions/$FUNCTION
$ faas-cli up -f functions.yml
```