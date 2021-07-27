## Overview

  In this task, we 're going to deploy the Infra of GKE with a custom VPC using `Terrafom`. Also, we enabled the autoscaling on the level of worker nodes and the HPA for the pods.

  After the Infra is up and running, we 're going to deploy a simple angular application using `helm` and expose this app to use HTTPS using ingress.


  ### Provision the infra

  - We 're going to create a GKE cluster with 1 node and enable the autoscaling feature in the us-central1-a zone

        cd terrafrom-gke
        terrafrom init
        terrafrom apply


### Create a tls  cert of the application

  - Copy the certificate and the private key under the cert folder
        cd cert
        kubectl create secret tls  devops-task --cert cert --key key

### Deploy the ingress controller to be able to use the ingress

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.48.1/deploy/static/provider/cloud/deploy.yaml
### Deploy the application using helm

- We already enabled the ingress and the hpa in the values.yml

      helm install test helm


### Test the autoscaling "HPA" of the application, by generating some load
    kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01;001 do wget -q -O- http:////test-helm; done"

  - open a new terminal and check the number of replicas, the max is `5`

        kubectl get pods  


### Test the autoscaling  of the nodes using stress tool, the max is `3`
    kubectl run stress --image=nginx
    kubectl exec -it stress -- /bin/sh
    apt update ; apt install stress -y
    stress --cpu 6 --io 3 --vm 5 --vm-bytes 10240M --timeout 200s

  - After 2-3 minutes, run `kubectl get nodes` to see the new nodes
