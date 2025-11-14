#admin passw: k3sadmin123!!
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

# export kubeconfig
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
                                                   
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

$CLUSTER_NAME = "k3s_arc"
$RESOURCE_GROUP = "k3s-cluster2-rg"
$TOKEN = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjVWcVcybEJsSlpnM2Nuc2dkdzBGRElkRTY5dFdKd0ZIeUJkQU1HcG1zMHcifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImRlbW8tdXNlci1zZWNyZXQiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVtby11c2VyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiNjdiNzYxMDQtMzBmNi00ZGE2LTlhYWUtNTc4YjM0OWE3ZmJkIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmRlZmF1bHQ6ZGVtby11c2VyIn0.eoSctXhg-uAstZghW5Mn-6uNjhKICLpEKEog3eJqSR8dvHDqSCEXHqiY4KX_gj7tubgp-uq9wOoTlR6NkJIbsxlEqqSbQS4I62B1eLQ-29dPMMRrW_NTKwAxz13b1q6SGu8zVgQAZxsOKqnRQUU9iRBqtQPTFCvPl9or6Tm709C5prTia1lY9MbRCt4SPenB9dh5wMy5SXBLe6FV1UIyTlGnJQjnKeRubL7Gfy-liUH4TjoJ_7BB-K32Afb7qhwtlvyaC6UsEzh7t7FR262iGsWoG2nJQ4SQCa0gsZOVfn0Mqf-unhd_vYg3DteQD-sqrIqt6DacCh8zdQBJNlNuVQ"
az connectedk8s proxy -n $CLUSTER_NAME -g $RESOURCE_GROUP --token $TOKEN

#proxy with entra ID
CLUSTER_NAME=k3s-demo
RESOURCE_GROUP=k3s-cluster2-rg
az connectedk8s proxy -n $CLUSTER_NAME -g $RESOURCE_GROUP
