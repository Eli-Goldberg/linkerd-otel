# Linkerd with OpenTelemetry and OpenObserve

This repository contains helper source files for deploying Linkerd with OpenTelemetry (OTel) and OpenObserve to collect Linkerd's metrics without deploying the Linkerd-viz extension.

## Overview

This setup demonstrates how to:
- Deploy Linkerd service mesh on a Kubernetes cluster
- Collect Linkerd metrics using OpenTelemetry Collector
- Send metrics to OpenObserve for visualization and analysis
- Achieve observability without the Linkerd-viz extension

## Components

### 1. `launch.sh` - Automated Setup Script
A comprehensive bash script that automates the entire deployment process:

- **Cluster Setup**: Creates a k3d cluster named `linkerd-otel`
- **OpenObserve Installation**: Installs OpenObserve standalone using Helm
- **Linkerd Installation**: 
  - Installs Linkerd CLI
  - Deploys Kubernetes Gateway API CRDs
  - Installs Linkerd control plane
- **Demo Application**: Deploys and injects the EmojiVoto demo app with Linkerd
- **OTel Collector**: Deploys the OpenTelemetry Collector configuration

### 2. `otel-collector.yaml` - OpenTelemetry Configuration
A complete Kubernetes manifest that sets up:

- **Namespace**: Creates `observability` namespace
- **RBAC**: Service account and cluster role for metric collection
- **ConfigMap**: OpenTelemetry Collector configuration with:
  - **Receivers**: Prometheus receiver configured for Linkerd metrics
  - **Exporters**: OTLP exporter to OpenObserve and debug exporter
  - **Pipelines**: Metrics pipeline from Prometheus to OpenObserve
- **Deployment**: OpenTelemetry Collector deployment with proper resource limits

## Key Features

### Linkerd Metrics Collection
The OpenTelemetry Collector is configured to scrape three types of Linkerd metrics:
- **linkerd-controller**: Control plane component metrics
- **linkerd-multicluster-controller**: Multi-cluster controller metrics  
- **linkerd-proxy**: Proxy metrics from all injected workloads

### OpenObserve Integration
- Sends metrics to OpenObserve via OTLP protocol
- Uses basic authentication with default credentials
- Configures proper labels and metadata for Linkerd metrics

### Security & Resource Management
- Runs collector as non-root user
- Implements proper RBAC permissions
- Sets resource limits and requests
- Uses secure TLS configuration

## Usage

### Quick Start
1. Make the script executable:
   ```bash
   chmod +x launch.sh
   ```

2. Run the automated setup:
   ```bash
   ./launch.sh
   ```

3. Access OpenObserve UI (in a separate terminal):
   ```bash
   kubectl port-forward -n openobserve svc/openobserve-openobserve-standalone 5080:5080
   ```
   Then visit: http://localhost:5080

4. Optional: Access EmojiVoto demo app:
   ```bash
   kubectl -n emojivoto port-forward svc/web-svc 8080:80
   ```
   Then visit: http://localhost:8080

### Manual Deployment
If you prefer manual deployment, you can run the commands from `launch.sh` individually or apply the OpenTelemetry configuration directly:

```bash
kubectl apply -f otel-collector.yaml
```

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Linkerd       │    │  OpenTelemetry   │    │   OpenObserve   │
│   Proxies       │───▶│   Collector      │───▶│   (Metrics DB)  │
│   & Control     │    │                  │    │                 │
│   Plane         │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Benefits

- **Lightweight**: No need for Linkerd-viz extension
- **Flexible**: Use any observability backend that supports OTLP
- **Production Ready**: Proper RBAC, resource limits, and security
- **Comprehensive**: Collects all essential Linkerd metrics
- **Standardized**: Uses OpenTelemetry standards for interoperability

## Prerequisites

- Docker and k3d installed
- kubectl configured
- Helm installed
- Internet access for downloading components

## Notes

- This setup uses Linkerd edge version for latest features
- OpenObserve runs in standalone mode suitable for development/testing
- The EmojiVoto demo app is included for testing the setup
- All components are deployed in their respective namespaces for isolation
