# Uses the first seven characters of the current commit-SHA 
# as the version to uniquely identify the artifacts from this build
export VERSION=$(git rev-parse HEAD | cut -c1-7)

# Builds and pushe to a container registry with the unique version
export NEW_IMAGE="jehadnasser/sample-web-app:${VERSION}"
docker build -t ${NEW_IMAGE} .
docker push ${NEW_IMAGE}

# Clones the Git deployment repo containing the Kubernetes manifests
git clone git@github.com:jehadnasser/demo-k8s-deploy.git
cd demo-k8s-deploy

# Updates the manifests with the new image tag
kubectl patch \
  --local \
  -o yaml \
  -f deployment.yaml \
  -p "spec:
        template:
          spec:
            containers:
            - name: sample-app
              image: ${NEW_IMAGE}" \
  > /tmp/newdeployment.yaml
mv /tmp/newdeployment.yaml deployment.yaml

# Commits and pushes the manifest changes to the deployment cofig repo(the gitops source of truth)
git commit deployment.yaml -m "Automatic: Update sample-app image to ${NEW_IMAGE}"
git push
