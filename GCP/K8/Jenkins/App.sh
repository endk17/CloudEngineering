#!/bin/bash

cd sample-app

# Create K8 Namespace
kubectl create ns production

# K8 Apply
kubectl apply -f k8s/production -n production
kubectl apply -f k8s/canary -n production
kubectl apply -f k8s/services -n production

# Scale K8 beyond default
kubectl scale deployment gceme-frontend-production -n production --replicas 4

#############################################################################
# 5 pods running for the frontend                                           #
# 4 for production traffic and 1 for canary releases                        #
# Changes to the canary release will only affect 1 out of 5 (20%) of users) #
#############################################################################

kubectl get pods -n production -l app=gceme -l role=frontend

# 2 pods for the backend, 1 for production and 1 for canary:
kubectl get pods -n production -l app=gceme -l role=backend

kubectl get service gceme-frontend -n production

# Store Frontend LoadBal IP to Var
export FRONTEND_SERVICE_IP=$(kubectl get -o jsonpath="{.status.loadBalancer.ingress[0].ip}" --namespace=production services gceme-frontend)