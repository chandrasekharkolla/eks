# Kubernetes Demo
## _Create EKS Cluster using TF configs_

The de facto application for managing Kubernetes and Istio is the bookinfo app

```
terragrunt run-all apply|plan
```
1. ✨VPC ✨
2. ✨EKS Cluster ✨
3. ✨AWS LB controller ✨
4. Kube config
```
aws eks update-kubeconfig --region us-east-1 --name my-cluster
```

## _Deploy Bookinfo application_
1. Deploy app of type loadbalancer using manifests
   ```
   cd app_manifests
   k apply -f bookinfo.yaml
   k get po
   k get svc
   ```
2. Access it from the web
   ```
   http://product-page-209c816045ab648b.elb.us-east-1.amazonaws.com:9080/productpage
   ```
3. Cleanup
    ```
    kubectl delete -f .
    ```

## _ArgoCD_

1. Install <code style="color : orange">argocd</code> using <code style="color : orange">Terrafom</code>
    ```
    terragrunt apply
    ```
2. Configure <code style="color : orange">argocd</code> using below commands
    ```
    argocd githb command
    ```
3. Setup the argocd app of apps
    ```
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

    argocd login $(kubectl get svc argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname') --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d) --insecure

    argocd account update-password --current-password 

    argocd repo add "https://gitlab.com/chandrasekharkolla/eks.git" --username chandrasekharkolla --password "glpat-iyjZs7gPhtpEF7xbgWao"

    k apply -f gitops/argo_apps/argocd.yaml
    ```
4. See how resources got created and access the app again from the browser
5. Change the svc type from LoadBalancer to ClusterIP
6. Checkin the code with svc of type ClusterIP

## _Istio_

- ##### Traffic management
- ##### Security
- ##### Observability

1. Label the namespace
2. Install istio
    ```
    terragrunt apply
    ```
3. Restart deployments in the istio configured namespace
4. Create istio configs
5. Acces the app using istio GW
6. Checkin traffic split peice and deploy mutiple versions of the app
7. - ###### A/B testing
   - ###### Mutual TLS
   - ###### Routing % using canary
   - ###### Fault injection
8. Install monitoring tools kiali, grafana, prometheus