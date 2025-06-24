#admin passw: K3sPassword123!!!
#create bicep resource deployment
az group create --name k3s-cluster2-rg --location westus
New-AzResourceGroupDeployment `
    -Name "k3s-deployment-$(Get-Date -Format 'yyyyMMddHHmmss')" `
    -ResourceGroupName "k3s-cluster2-rg" `
    -TemplateFile "main.bicep" `
    -TemplateParameterFile "main.parameters.json"

ssh k3sadmin@13.91.251.80

# install AZ-CLI
sudo su -
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Create connected cluster (PORTAL SCRIPT
az connectedk8s connect --name "k3s2" --resource-group "k3s-cluster2-rg" --location "westus" --correlation-id "c18ab9d0-685e-48e7-ab55-12588447b0ed" --tags "Datacenter City StateOrDistrict CountryOrRegion"

#show current connected user
az account show --query user



az ssh vm --ip 13.91.251.80

sudo kubectl apply -f nginx-deployment.yaml
sudo kubectl expose deployment nginx-deployment --type=NodePort --port=80
sudo kubectl apply -f nginx-ingress.yaml
vi /etc/hosts
  10.43.175.61 nginx.local

sudo kubectl get services
sudo kubectl apply -f nginx-service.yaml



# export KUBECONFIG 
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml


#Service Account
kubectl create serviceaccount demo-user -n default
kubectl create clusterrolebinding demo-user-binding --clusterrole cluster-admin --serviceaccount default:demo-user
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: demo-user-secret
  annotations:
    kubernetes.io/service-account.name: demo-user
type: kubernetes.io/service-account-token
EOF
TOKEN=$(kubectl get secret demo-user-secret -o jsonpath='{$.data.token}' | base64 -d | sed 's/$/\n/g')

#PROXY with token
CLUSTER_NAME=k3s-demo
RESOURCE_GROUP=k3s-cluster-rg
TOKEN=eyJhbGciOiJSUzI1NiIsImtpZCI6Ijd4MXV5MURNOEc0WElySno2M2dFanZPN21CNzRiaGsySEd6dkxVM3pGV3cifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImRlbW8tdXNlci1zZWNyZXQiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVtby11c2VyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiMDQzOWNiZTYtMTJkYy00MDA1LTljM2YtNmJmOGZiNjhhNTBiIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmRlZmF1bHQ6ZGVtby11c2VyIn0.iCWpCKW-pchJNcNAUgJwtguFfDUDa-XX3vjFc-UrW-Jaad8bQfeiSkTJO054f-u94R2PLPE13BG2B_3yscbuClQt9InH0bcYFsGChxLIiKGNltiAO4LWVgyEm-PAlFwhd7-jkBE3FPtGNWgYTtMfNs0galz_vNHFC5iC3IL7Ut2WyOBk9SgMsv4frDXpXEqwq4hYozaXRnKjr3cnGpFzZ8tk1WWQ4fzdCttBHw0kHhRGJXcQN2l478ZhzdRQePt0Tf3KNAscXcVWQX9pPTJbyM2MROV9BKTDqqoBzUl2xcQYym42oQzh24GyN51LdNAc_vaQFDFbw3Gz8TxSkcs2dw
az connectedk8s proxy -n $CLUSTER_NAME -g $RESOURCE_GROUP --token $TOKEN

#proxy with entra ID
CLUSTER_NAME=k3s-demo
RESOURCE_GROUP=k3s-cluster-rg
az connectedk8s proxy -n $CLUSTER_NAME -g $RESOURCE_GROUP
