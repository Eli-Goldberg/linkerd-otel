#!/bin/bash

k3d cluster create linkerd-otel

helm repo add openobserve https://openobserve.github.io/helm-charts/
helm repo update

helm install --wait --create-namespace -n openobserve openobserve openobserve/openobserve-standalone

# On a different terminal, run:
# kubectl port-forward -n openobserve svc/openobserve-openobserve-standalone 5080:5080

# Install Linkerd CLI
curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install-edge | sh

# Install k8s gateway api CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml

# install Linkerd on the cluster
linkerd install --crds | kubectl apply -f -
linkerd install | kubectl apply -f -

# Install the EmojiVoto Demo App
curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/emojivoto.yml | kubectl apply -f -

# inject Linkerd into the EmojiVoto Demo App
kubectl get -n emojivoto deploy -o yaml | linkerd inject - | kubectl apply -f -

# verify EmojiVoto is running
linkerd -n emojivoto check --proxy

# [Optional] If you want to access the EmojiVoto Demo App, run:
# On a different terminal, run:
# kubectl -n emojivoto port-forward svc/web-svc 8080:80


# [Optional] We don't need viz at all, but if you want to install it, run:
# On a different terminal, run:
# linkerd viz install | kubectl apply -f -


kubectl apply -f otel-collector.yaml