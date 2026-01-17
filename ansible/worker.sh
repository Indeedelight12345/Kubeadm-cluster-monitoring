# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install Cert-Manager
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true


  -----------
  # Add the Rancher Helm repository
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update

# Install Rancher
# Replace 136.113.203.182 with your Master IP if it has changed
helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --create-namespace \
  --set hostname=136.113.203.182.sslip.io \
  --set bootstrapPassword=admin \
  --set replicas=1


  --------
  kubectl patch svc rancher -n cattle-system -p '{"spec": {"type": "NodePort"}}'

  -------
  gcloud compute firewall-rules create allow-rancher-https \
    --allow tcp:32162 \
    --description="Allow Rancher UI HTTPS" \
    --direction=INGRESS

    -----------
    kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{ .data.bootstrapPassword|base64decode}}{{"\n"}}'