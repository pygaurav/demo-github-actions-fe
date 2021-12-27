if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

echo $DOCKER_PASSWORD | docker login orglabel.jfrog.io -u $DOCKER_USERNAME --password-stdin
docker build frontend -t orglabel.jfrog.io/default-docker-virtual/demogithubfe:latest
docker build backend -t orglabel.jfrog.io/default-docker-virtual/demogithubbe:latest
docker push orglabel.jfrog.io/default-docker-virtual/demogithubfe:latest
docker push orglabel.jfrog.io/default-docker-virtual/demogithubbe:latest
SECRET_DOCKER='{"auths":{"orglabel.jfrog.io":{"username": "'"$DOCKER_USERNAME"'","password":"'"$DOCKER_PASSWORD"'"}}}'
echo $SECRET_DOCKER> .dockerconfig.json
microk8s kubectl delete secret jfrogauth
microk8s kubectl create secret docker-registry jfrogauth --from-file=.dockerconfigjson=.dockerconfig.json -o yaml
rm .dockerconfig.json
microk8s kubectl apply -f k8s/deployments/backend.yaml
microk8s kubectl apply -f k8s/deployments/frontend.yaml
microk8s kubectl apply -f k8s/services/backend.yaml
microk8s kubectl apply -f k8s/services/frontend.yaml
