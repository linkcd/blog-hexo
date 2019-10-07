---
title: Jump-start Kubernetes and Istio with Docker Desktop on Windows 10
date: 2019-10-05 19:57:31
tags:
- Docker
- Kubernetes
- Istio
- Service mesh
- Kiali
- Jump-start
---
Here we will setup a single-node Kubernetes cluster on a windows 10 PC (In my case it is a surface 5 with 16GB RAM). If you are new to docker, feel free to check out [Jump-start with docker](/2017/03/31/Jump-start-ASP-Net-Core-with-Docker/).
We are going to setup:
- A single-node Kubernetes cluster
- [Kubernetes dashboard](https://github.com/kubernetes/dashboard)
- Helm
- Isito (service mesh, including Kiali)

{% asset_img "Title picture.png" "" %}

<!-- more -->

# 1. Enable Kubernetes in Docker Desktop
[Docker Desktop (or Docker for Windows)](https://docs.docker.com/docker-for-windows/) is a nice environment for developers on Windows. The community stable version of Docker Desktop is good enough for this jump-start, just make sure the version you installed include Kubernetes 1.14.x or higher. (I am using Docker Desktop Community 2.1.0.3).

Once installed, you can enable Kubernetes in Setting (see detailed info at [here](https://docs.docker.com/docker-for-windows/#kubernetes))
{% asset_img "Enable Kubernetes in setting.png" "Enable Kubernetes in setting" %}

Then, you can verify it by running "**kubectl version**" in powershell (or Command window)

In my case, I got error while connecting to [::1]:8080:
```bash
PS C:\> kubectl version
#Output:
Client Version: version.Info{Major:"1", Minor:"14", GitVersion:"v1.14.3", GitCommit:"5e53fd6bc17c0dec8434817e69b04a25d8ae0ff0", GitTreeState:"clean", BuildDate:"2019-06-06T01:44:30Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"windows/amd64"}
Unable to connect to the server: dial tcp [::1]:8080: connectex: No connection could be made because the target machine actively refused it.
```

This is because I am missing an environment variable "**KUBECONFIG**". Set this variable to your user directory such as "**C:\Users\USERNAME\.kube\config**". 

After adding this and restart your powershell, it should work.
```bash
PS C:\> Get-Item -Path Env:KUBECONFIG
#Output:
Name                           Value
----                           -----
KUBECONFIG                     C:\Users\lufeng\.kube\config

PS C:\> kubectl version
#Output:
Client Version: version.Info{Major:"1", Minor:"14", GitVersion:"v1.14.3", GitCommit:"5e53fd6bc17c0dec8434817e69b04a25d8ae0ff0", GitTreeState:"clean", BuildDate:"2019-06-06T01:44:30Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"windows/amd64"}
Server Version: version.Info{Major:"1", Minor:"14", GitVersion:"v1.14.3", GitCommit:"5e53fd6bc17c0dec8434817e69b04a25d8ae0ff0", GitTreeState:"clean", BuildDate:"2019-06-06T01:36:19Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}

PS C:\> kubectl get namespaces
#Output:
NAME              STATUS   AGE
default           Active   18h
docker            Active   18h
kube-node-lease   Active   18h
kube-public       Active   18h
kube-system       Active   18h
```

# 2. Installing Kubernetes Dashboard
It is always nice to have a GUI for a complicated system such as Kubernetes, so lets install the dashboard https://github.com/kubernetes/dashboard. 

## 2.1 Dashboard deployment
```bash
PS C:\> kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
#Output:
secret/kubernetes-dashboard-certs created
serviceaccount/kubernetes-dashboard created
role.rbac.authorization.k8s.io/kubernetes-dashboard-minimal created
rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard-minimal created
deployment.apps/kubernetes-dashboard created
service/kubernetes-dashboard created
```

## 2.2 Accessing the dashboard
First of all, we need to enable the proxy, so you can access the dashboard from your localhost:
```bash
PS C:\> kubectl proxy
#Output:
Starting to serve on 127.0.0.1:8001
```
Once the proxy is up and running, visit the dashboard URL: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

Normally you will meet this [login view] (https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/README.md#login-view)
{% asset_img "Dashboard login.png" "Dashboard login" %}

You can find more info from the dashboard github about [Access control](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/README.md), but here we will do it simpler (This is for demo purpose, do not apply the same setup in your production environment).

### 2.2.1 Get token
Get the default token name
```bash
PS C:\> kubectl get secrets
#Output:
NAME                  TYPE                                  DATA   AGE
default-token-n92hz   kubernetes.io/service-account-token   3      18h
```

Then get the token
```bash
PS C:\> kubectl describe secrets default-token-n92hz
#Output:
Name:         default-token-n92hz
Namespace:    default
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: default
              kubernetes.io/service-account.uid: c56ad00e-e5e5-11e9-91a0-00155d3a9005
Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  7 bytes
token:      eyJhbGciOiJSUzI1NiIsImt3NlcnZpY2UtYWNjb......CIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjfv4TPDVZoOrLWHZecEw-8XBQ
PS C:\>
```
Use the token in the login form, then you are in.

{% asset_img "Kubernetes Dashboard.png" "Kubernetes Dashboard Overview" %}

# 3. Installing Helm on Windows
Helm is a tool for managing Kubernetes charts. Charts are packages of pre-configured Kubernetes resources. You can read more at https://helm.sh/.
According to the [installation guide](https://helm.sh/docs/using_helm/#installing-helm), we are going to:
1. Install [scoop](https://scoop.sh/)
2. Install helm via scoop
```bash
PS C:\> scoop install helm
```
3. Ensure configure the environment variable for "**HELM_HOME**", such as "C:\Users\USERNAME\.kube". It should be an valid directory in your file system.
```bash
PS C:\> Get-Item -Path Env:HELM_HOME
#Output:
Name                           Value
----                           -----
HELM_HOME                      C:\Users\lufeng\.kube
```
4. Initialize Helm and install Tiller
Once you have Helm ready, you can initialize the local CLI and also install Tiller into your Kubernetes cluster in one step:
```bash
#Check current kubernetes cluster context
PS P:\> kubectl config current-context
#Output:
docker-desktop

#Init helm
PS C:\> helm init --history-max 200
#Output:
$HELM_HOME has been configured at C:\Users\lufeng\.kube.
Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.

#Verify the triller is up and running (the last row)
PS C:\> kubectl get pods --namespace kube-system
#Output:
NAME                                     READY   STATUS    RESTARTS   AGE
coredns-fb8b8dccf-b5lq5                  1/1     Running   0          19h
coredns-fb8b8dccf-t5kdf                  1/1     Running   0          19h
etcd-docker-desktop                      1/1     Running   0          19h
kube-apiserver-docker-desktop            1/1     Running   0          19h
kube-controller-manager-docker-desktop   1/1     Running   0          19h
kube-proxy-bj2x4                         1/1     Running   0          19h
kube-scheduler-docker-desktop            1/1     Running   0          19h
kubernetes-dashboard-5f7b999d65-vqdq6    1/1     Running   0          19h
tiller-deploy-5454fb964d-8tp5t           1/1     Running   0          76s
```

# 4. Installing Istio
[Istio](istio.io) is a microservice-mesh management framework, that provides traffic management, policy enforcement, and telemetry collection.
We are going to:
- Install Istio (and addons such as Kiali) via Helm ([doc](https://istio.io/docs/setup/install/helm/))
- Accessing Kiali dashboard ([doc](https://istio.io/docs/tasks/telemetry/kiali/))
- Install bookinfo demo ([doc](https://istio.io/docs/examples/bookinfo/))


## 4.1 Install Istio via Helm
Simply follow the steps in https://istio.io/docs/setup/install/helm/, remember to config docker desktop [as mentioned](https://istio.io/docs/setup/platform-setup/docker/). Unzip the downloaded package into "**c:\Istio**" as we might want to update some files there.

```bash
PS C:\> helm repo add istio.io https://storage.googleapis.com/istio-release/releases/1.3.1/charts/
#Output:
"istio.io" has been added to your repositories

#Use Helm’s Tiller pod to manage Istio release (option 2), as we installed Tiller in previous step.
PS C:\> cd istio

#1. Make sure you have a service account with the cluster-admin role defined for Tiller. If not already defined, create one using following command
PS C:\istio> kubectl apply -f install/kubernetes/helm/helm-service-account.yaml
#Output:
serviceaccount/tiller created
clusterrolebinding.rbac.authorization.k8s.io/tiller created

#2. Config Tiller on your cluster with the service account:
PS C:\istio> helm init --upgrade --service-account tiller
#Output:
$HELM_HOME has been configured at C:\Users\lufeng\.kube.
Tiller (the Helm server-side component) has been upgraded to the current version.

#3. Install the istio-init chart to bootstrap all the Istio’s CRDs:
PS C:\istio> helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system
#Output:
NAME:   istio-init
LAST DEPLOYED: Fri Oct  4 11:36:15 2019
NAMESPACE: istio-system
STATUS: DEPLOYED

RESOURCES:
==> v1/ClusterRole
NAME                     AGE
istio-init-istio-system  0s

==> v1/ClusterRoleBinding
NAME                                        AGE
istio-init-admin-role-binding-istio-system  0s

==> v1/ConfigMap
NAME          DATA  AGE
istio-crd-10  1     0s
istio-crd-11  1     0s
istio-crd-12  1     0s

==> v1/Job
NAME                     COMPLETIONS  DURATION  AGE
istio-init-crd-10-1.3.1  0/1          0s
istio-init-crd-11-1.3.1  0/1          0s  0s
istio-init-crd-12-1.3.1  0/1          0s  0s

==> v1/Pod(related)
NAME                           READY  STATUS             RESTARTS  AGE
istio-init-crd-11-1.3.1-qz4fh  0/1    ContainerCreating  0         0s
istio-init-crd-12-1.3.1-6rk5w  0/1    ContainerCreating  0         0s

==> v1/ServiceAccount
NAME                        SECRETS  AGE
istio-init-service-account  1        0s
```

Then select a [configuration profile](https://istio.io/docs/setup/additional-setup/config-profiles/). We go with "**demo**" as it include some nice addons such as Kiali. 
```bash
#Installation
PS C:\istio> helm install install/kubernetes/helm/istio --name istio --namespace istio-system --values install/kubernetes/helm/istio/values-istio-demo.yaml

#Verify
PS C:\istio>  kubectl get pods -n istio-system
#Output:
NAME                                      READY   STATUS      RESTARTS   AGE
grafana-6fc987bd95-zj4kn                  1/1     Running     0          98s
istio-citadel-55646d8965-wvflc            1/1     Running     0          97s
istio-egressgateway-7bdb7bf7b5-ck4k6      1/1     Running     0          98s
istio-galley-56bf6b7497-c9szw             1/1     Running     0          98s
istio-ingressgateway-64dbd4b954-64gj8     1/1     Running     0          98s
istio-init-crd-10-1.3.1-tvnr4             0/1     Completed   0          4h1m
istio-init-crd-11-1.3.1-qz4fh             0/1     Completed   0          4h1m
istio-init-crd-12-1.3.1-6rk5w             0/1     Completed   0          4h1m
istio-pilot-5d4c86d576-crn2k              2/2     Running     0          97s
istio-policy-759d4988df-c7tnb             2/2     Running     1          97s
istio-sidecar-injector-5d6ff6d758-8tlrx   1/1     Running     0          97s
istio-telemetry-7c88764b9c-245mk          2/2     Running     1          97s
istio-tracing-669fd4b9f8-gmlh9            1/1     Running     0          97s
kiali-94f8cbd99-zwz8z                     1/1     Running     0          98s
prometheus-776fdf7479-jwnvh               1/1     Running     0          97s
```
You can also verify these pod via dashboard
{% asset_img "Istio pods.png" "Istio pods in dashboard" %}

## 4.2 Accessing Kiali dashboard
As we installed the **Demo** configuration profile of Istio, Kiali was also installed. [Kiali](https://www.kiali.io/) is an observability console for Istio with service mesh configuration capabilities. (Read more at https://istio.io/docs/tasks/telemetry/kiali/ also)

To open Kiali UI, pls run
```bash
PS C:\istio> kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001
#Output:
Forwarding from 127.0.0.1:20001 -> 20001
Forwarding from [::1]:20001 -> 20001
```
Then go to http://localhost:20001 for visting Kiali UI.

Again, it ask for login. As in this case, Kiali was installed as a part of the **Demo** configuration profile, you can use default user name "**admin**" and password "**admin**" to login.
{% asset_img "Kiali login.png" "Kiali login form" %}


## 4.3 Install bookinfo demo
Now, lets deploy a demo application composed of four separate microservices. The detailed doc can be found at https://istio.io/docs/examples/bookinfo/. 

1. Start the application services
```bash
#1. Set automatic sidecar injection
PS C:\istio> kubectl label namespace default istio-injection=enabled

#2. Deployment
PS C:\istio> kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
#Output:
service/details created
serviceaccount/bookinfo-details created
deployment.apps/details-v1 created
service/ratings created
serviceaccount/bookinfo-ratings created
deployment.apps/ratings-v1 created
service/reviews created
serviceaccount/bookinfo-reviews created
deployment.apps/reviews-v1 created
deployment.apps/reviews-v2 created
deployment.apps/reviews-v3 created
service/productpage created
serviceaccount/bookinfo-productpage created
deployment.apps/productpage-v1 created

#3. Verify services and pods
PS C:\istio> kubectl get services
#Output:
NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
details       ClusterIP   10.110.165.24   <none>        9080/TCP   33s
kubernetes    ClusterIP   10.96.0.1       <none>        443/TCP    6h50m
productpage   ClusterIP   10.97.123.119   <none>        9080/TCP   32s
ratings       ClusterIP   10.111.216.40   <none>        9080/TCP   33s
reviews       ClusterIP   10.109.244.28   <none>        9080/TCP   33s

PS C:\istio> kubectl get pods
#Output:
NAME                             READY   STATUS    RESTARTS   AGE
details-v1-c5b5f496d-sgr6w       2/2     Running   0          85s
productpage-v1-c7765c886-6cpr9   2/2     Running   0          83s
ratings-v1-f745cf57b-87m7q       2/2     Running   0          85s
reviews-v1-75b979578c-vmzn2      2/2     Running   0          84s
reviews-v2-597bf96c8f-plml7      2/2     Running   0          85s
reviews-v3-54c6c64795-x67ss      2/2     Running   0          84s

#4. Verify by calling the application
PS C:\istio> kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | select-string -pattern "<title>"
#Output:
    <title>Simple Bookstore App</title>
```

2. Establish gateway for the bookinfo app
```bash
#1. Apply gateway
PS C:\istio> kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
#Output:
gateway.networking.istio.io/bookinfo-gateway created
virtualservice.networking.istio.io/bookinfo created

#2. Verify the gateway
PS C:\istio> kubectl get gateway
#Output:
NAME               AGE
bookinfo-gateway   38s
```

3. Confirm the app is accessible from outside the cluster
Go to http://localhost/productpage to verify you can open the page. You can refresh the page several times for generating telemtries. 
{% asset_img "Bookinfo demo.png" "Bookinfo demo page" %}

4. Kiali Visualization
Assuming the 20001 port forwarding is still running, then you can visualize the service relationship in Kiali http://localhost:20001/
{% asset_img "Kiali graph.gif" "Kiali graph" %}

# 5. Summary
Now, you should have a kubernetes environment up and running, together with Istio and Kiali enabled. It can be used as your sandbox, for developing and testing your applications in Kubernetes. With Istio and Kiali, you can also play with service mesh. Everything is running locally in "one box", so you do not need to worry about any cloud running cost.

Have fun.