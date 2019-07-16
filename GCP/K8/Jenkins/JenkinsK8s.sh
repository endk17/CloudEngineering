#!/bin/bash

gcloud config set compute/zone us-central1-f
git clone https://github.com/GoogleCloudPlatform/continuous-deployment-on-kubernetes.git

cd continuous-deployment-on-kubernetes

# Provision K8 cluster
gcloud container clusters create jenkins-cd \
--num-nodes 2 \
--machine-type n1-standard-2 \
--scopes "https://www.googleapis.com/auth/projecthosting,cloud-platform"

# Get Creds
gcloud container clusters get-credentials jenkins-cd

# Helm Install
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.14.1-linux-amd64.tar.gz

# Unzip
tar zxfv helm-v2.14.1-linux-amd64.tar.gz
cp linux-amd64/helm .

# Add a cluster administrator in the cluster's RBAC as to give Jenkins permissions in the cluster
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)

# Grant Tiller, the server side of Helm, the cluster-admin role in your cluster
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

# Set up helm
./helm init --service-account=tiller
./helm update

# Install Jenkins
./helm install -n cd stable/jenkins -f jenkins/values.yaml --version 1.2.2 --wait

#Configure the Jenkins service account to be able to deploy to the cluster
kubectl create clusterrolebinding jenkins-deploy --clusterrole=cluster-admin --serviceaccount=default:cd-jenkins

# Setup port forwarding to the Jenkins UI 
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/component=jenkins-master" -l "app.kubernetes.io/instance=cd" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:8080 >> /dev/null &

# Admin PW
printf $(kubectl get secret cd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo