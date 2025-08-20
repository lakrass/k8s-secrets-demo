# CDS 2025 Demo
## Quickstart
1. Have kind, helm and helmfile installed
2. ``kind create cluster --config kind-config.yaml`` inside this directory
3. ``helm plugin install https://github.com/databus23/helm-diff``
4. ``helmfile apply`` inside this directory