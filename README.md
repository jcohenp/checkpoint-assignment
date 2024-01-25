
# Checkpoint challenge 

This repository contains 2 Docker microservices in Python built on EKS, S3 bucket, ELB and SQS

## Prerequisites

- **Git**: For cloning the repository and managing the source code.
- **localstack**: To run the system locally 

## Folder Structure:

- **apps/**: Contains microservices to process requests, push it to a queue and write the data on s3 bucket
  - **message_broker**: used for writing post data to a S3 bucket when the SQS queue get a message
    - **Dockerfile**: Instructions to build the docker image
    - **message_broker.py**: python script to listen on the SQS queue and write data to s3 bucket
    - **requirements.txt**: set all necessary dependencies for our message_broker app
  - **processing_requests**: script to install ansible on ubuntu system
    - **Dockerfile**: Instructions to build the docker image
    - **processing_requests.py**: Flask app to process requests and send data to queue
    - **requirements.txt**: set all necessary dependencies for our processing_requests app
- **terraform**: used to set up all infrastructures
    - **modules**: contains s3, sqs, eks, ssm modules
    - **main.tf**: used as general main for the terraform, used to run modules 
    - **variables.tf**: used to set up var used in the main.tf file
- **k8s**: Contains the kubernetes yaml files to deploy the flask app
    - **deployment.yaml**: deployment of the flask app
    - **flask-svc.yaml**: service to expose the deployment
- **docker-compose.yaml**: used to run localstack
- **README.md**: This document providing instructions, explanations, and a guide on how to use the repository.


### Configuration:

1. **Clone this repository:**

    ```
    git clone https://github.com/jcohenp/checkpoint-assignment.git
    ```
2. **Build the Docker Image:**

    ```
    docker build -t processing_requests .
    ```
3. **Create a tag:**

    ```
    sudo docker tag <imageID> jcohenp/checkpoint-exam
    ```
4. **Push the image in the Docker registry**

    ```
    sudo docker push jcohenp/checkpoint-exam
    ```
    
5. **move to the terraform repository**:
    ```
    cd terraform
    ``` 
6. **Initialized the terraform repos using tflocal:**

    ```
    tflocal init
    ```

7. **create a plan using tflocal:**

    ```
    tflocal plan
    ```
    
8. **apply your change using tflocal:**
    
    ```
    tflocal apply --auto-approve
    ```

9. **Check if everything is setup on your localstack environment:**
    
    **docker ps**
    ```
    CONTAINER ID   IMAGE                            COMMAND                  CREATED        STATUS                  PORTS                                                                                              NAMES
    b319705d65eb   ee6507fdfdfe                     "/bin/k3d-entrypoint…"   14 hours ago   Up 14 hours                                                                                                                k3d-my-eks-cluster-agent-ng-1-0
    d7d26c101af5   ghcr.io/k3d-io/k3d-tools:5.6.0   "/app/k3d-tools noop"    14 hours ago   Up 14 hours                                                                                                                k3d-my-eks-cluster-tools
    09921e0c5b09   ghcr.io/k3d-io/k3d-proxy:5.6.0   "/bin/sh -c nginx-pr…"   14 hours ago   Up 14 hours             0.0.0.0:6443->6443/tcp, 0.0.0.0:8081->80/tcp                                                       k3d-my-eks-cluster-serverlb
    4ed2b94b50df   rancher/k3s:v1.22.6-k3s1         "/bin/k3d-entrypoint…"   14 hours ago   Up 14 hours                                                                                                                k3d-my-eks-cluster-server-0
    e84c50d49c9e   localstack/localstack-pro        "docker-entrypoint.sh"   14 hours ago   Up 14 hours (healthy)   0.0.0.0:443->443/tcp, 0.0.0.0:4510-4559->4510-4559/tcp, 53/tcp, 5678/tcp, 0.0.0.0:4566->4566/tcp   localstack-main

    ```
    **docker exec -it 4ed2b94b50df sh**: (connect to the eks cluster)
    
    **kubectl get all -A**:

    ```
    NAMESPACE     NAME                                              READY   STATUS      RESTARTS   AGE
    kube-system   pod/local-path-provisioner-84bb864455-fn48l       1/1     Running     0          13h
    kube-system   pod/metrics-server-ff9dbcb6c-6mjh6                1/1     Running     0          13h
    kube-system   pod/helm-install-traefik-crd--1-wqwgd             0/1     Completed   0          13h
    kube-system   pod/helm-install-traefik--1-p7gc5                 0/1     Completed   2          13h
    kube-system   pod/svclb-traefik-z6ggv                           2/2     Running     0          13h
    kube-system   pod/traefik-55fdc6d984-gkww7                      1/1     Running     0          13h
    kube-system   pod/coredns-88845c68d-qbq45                       1/1     Running     0          13h
    kube-system   pod/svclb-traefik-w2w68                           2/2     Running     0          13h
    default       pod/my-microservice-deployment-75df8c6445-cl5lf   1/1     Running     0          13h
    default       pod/my-microservice-deployment-75df8c6445-dmmvv   1/1     Running     0          13h
    default       pod/my-microservice-deployment-75df8c6445-ppvdt   1/1     Running     0          13h
    default       pod/nginx                                         1/1     Running     0          12h
    default       pod/svclb-my-microservice-service-4cvtd           1/1     Running     0          11h
    default       pod/svclb-my-microservice-service-88jng           1/1     Running     0          11h
    
    NAMESPACE     NAME                              TYPE           CLUSTER-IP      EXTERNAL-IP                 PORT(S)                      AGE
    default       service/kubernetes                ClusterIP      10.43.0.1       <none>                      443/TCP                      13h
    kube-system   service/kube-dns                  ClusterIP      10.43.0.10      <none>                      53/UDP,53/TCP,9153/TCP       13h
    kube-system   service/metrics-server            ClusterIP      10.43.225.105   <none>                      443/TCP                      13h
    kube-system   service/traefik                   LoadBalancer   10.43.75.172    192.168.96.3,192.168.96.6   80:30902/TCP,443:30729/TCP   13h
    default       service/my-microservice-service   LoadBalancer   10.43.7.144     192.168.96.3,192.168.96.6   5001:32657/TCP               11h
    
    NAMESPACE     NAME                                           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
    kube-system   daemonset.apps/svclb-traefik                   2         2         2       2            2           <none>          13h
    default       daemonset.apps/svclb-my-microservice-service   2         2         2       2            2           <none>          11h
    
    NAMESPACE     NAME                                         READY   UP-TO-DATE   AVAILABLE   AGE
    kube-system   deployment.apps/local-path-provisioner       1/1     1            1           13h
    kube-system   deployment.apps/metrics-server               1/1     1            1           13h
    kube-system   deployment.apps/traefik                      1/1     1            1           13h
    kube-system   deployment.apps/coredns                      1/1     1            1           13h
    default       deployment.apps/my-microservice-deployment   3/3     3            3           13h
    
    NAMESPACE     NAME                                                    DESIRED   CURRENT   READY   AGE
    kube-system   replicaset.apps/local-path-provisioner-84bb864455       1         1         1       13h
    kube-system   replicaset.apps/metrics-server-ff9dbcb6c                1         1         1       13h
    kube-system   replicaset.apps/traefik-55fdc6d984                      1         1         1       13h
    kube-system   replicaset.apps/coredns-96cc4f57d                       0         0         0       13h
    kube-system   replicaset.apps/coredns-88845c68d                       1         1         1       13h
    default       replicaset.apps/my-microservice-deployment-75df8c6445   3         3         3       13h
    
    NAMESPACE     NAME                                 COMPLETIONS   DURATION   AGE
    kube-system   job.batch/helm-install-traefik-crd   1/1           114s       13h
    kube-system   job.batch/helm-install-traefik       1/1           2m10s      13h
    ```

10. **Validate that the processing_requests microservice is reachable:**

    **wget --header="Content-Type: application/json" --post-data='{"data": {"email_subject": "Your Subject", "email_sender": "Your Sender", "email_timestream": "1706115212", "email_content": "Your Content"}, "token": "foobar"}' http://10.42.0.11:5001/process_request**

    ```
    --2024-01-25 08:49:49--  http://10.42.0.11:5001/process_request
    Connecting to 10.42.0.11:5001... connected.
    HTTP request sent, awaiting response... 200 OK
    Length: 50 [application/json]
    Saving to: ‘process_request’
    
    process_request                                   100%[============================================================================================================>]      50  --.-KB/s    in 0s      
    
    2024-01-25 08:49:49 (7.53 MB/s) - ‘process_request’ saved [50/50]
    
    root@my-microservice-deployment-75df8c6445-ppvdt:/app# cat ind
    cat: ind: No such file or directory
    root@my-microservice-deployment-75df8c6445-ppvdt:/app# cat 
    Dockerfile              app.log                 process_request         processing_requests.py  requirements.txt        
    root@my-microservice-deployment-75df8c6445-ppvdt:/app# cat process_request 
    {
      "message": "Request processed successfully"
    }
    ```

11. **Validate that the flask app is reachable outside the cluster (public ip on port 31401):**
    
    **not working**
    ```
    ```



