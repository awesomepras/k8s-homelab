!/bin/bash
##################################################
# this script can be used to setup kubernetes cluster that is being used by learn kubernetes the hard way
# https://github.com/mmumshad/kubernetes-the-hard-way/tree/master/docs
#https://github.com/allir/kubernetes-the-scripted-way
#
##################################################
echo "setup vagrant and bring the vagrant vm' up"
echo "edit the ssh config to include the vagrant user ssh key for master-{1,2), worker-{1,2}"
echo " create private and public keys for master-1 and copy it over to all other nodes"
ssh master-1 "ssh-keygen -t rsa -b 4096 -N '' -f ~/.ssh/id_rsa"
scp master-1:~/.ssh/id_rsa.pub ./master_id_rsa.pub 
ssh-copy-id -f -i master_id_rsa.pub master-2
ssh-copy-id -f -i master_id_rsa.pub worker-1
ssh-copy-id -f -i master_id_rsa.pub worker-2

echo #################################################;
echo run the following commands in master-1;
echo #################################################;

echo "install kubectl"
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" 
chmod +x kubectl;
sudo mv kubectl /usr/local/bin/;
echo Verify;
kubectl version --client;
# 04-certificate-authority.md;
echo #################################################;
echo run the following commands in master-1;
echo #################################################;
# Create private key for CA
openssl genrsa -out ca.key 4096;
# Comment line starting with RANDFILE in /etc/ssl/openssl.cnf definition to avoid permission issues
sudo sed -i '0,/RANDFILE/{s/RANDFILE/\#&/}' /etc/ssl/openssl.cnf

# Create CSR using the private key
openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr;

# Self sign the csr using its own private key
openssl x509 -req -in ca.csr -signkey ca.key -CAcreateserial  -out ca.crt -days 1000;
echo "#################################################"
echo "Generate the admin client certificate and private key" 
echo "#################################################"

# Generate private key for admin user
openssl genrsa -out admin.key 4096;


# Generate CSR for admin user. Note the OU.
openssl req -new -key admin.key -subj "/CN=admin/O=system:masters" -out admin.csr

# Sign certificate for admin user using CA servers private key;
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out admin.crt -days 1000;

#Generate the kube-controller-manager client certificate and private key:
openssl genrsa -out kube-controller-manager.key 4096;
openssl req -new -key kube-controller-manager.key -subj "/CN=system:kube-controller-manager" -out kube-controller-manager.csr;
openssl x509 -req -in kube-controller-manager.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kube-controller-manager.csr;
#Generate the kube-proxy client certificate and private key:

openssl genrsa -out kube-proxy.key 4096;
openssl req -new -key kube-proxy.key -subj "/CN=system:kube-proxy" -out kube-proxy.csr;
openssl x509 -req -in kube-proxy.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out kube-proxy.crt -days 1000;

#Generate the kube-scheduler client certificate and private key:

openssl genrsa -out kube-scheduler.key 4096;
openssl req -new -key kube-scheduler.key -subj "/CN=system:kube-scheduler" -out kube-scheduler.csr;
openssl x509 -req -in kube-scheduler.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out kube-scheduler.crt -days 1000;

#Create alt_DNS_names 

cat> openssl.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 10.96.0.1
IP.2 = 192.168.5.11
IP.3 = 192.168.5.12
IP.4 = 192.168.5.30
IP.5 = 127.0.0.1
EOF
;
#Generates certs for kube-apiserver
openssl genrsa -out kube-apiserver.key 4096;
openssl req -new -key kube-apiserver.key -subj "/CN=kube-apiserver" -out kube-apiserver.csr -config openssl.cnf;
openssl x509 -req -in kube-apiserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out kube-apiserver.crt -extensions v3_req -extfile openssl.cnf -days 1000;

#Genereate altnames for etcd-server
cat > openssl-etcd.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
IP.1 = 192.168.5.11
IP.2 = 192.168.5.12
IP.3 = 127.0.0.1
EOF
;
#Generates certs for ETCD

openssl genrsa -out etcd-server.key 4096;
openssl req -new -key etcd-server.key -subj "/CN=etcd-server" -out etcd-server.csr -config openssl-etcd.cnf;
openssl x509 -req -in etcd-server.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out etcd-server.crt -extensions v3_req -extfile openssl-etcd.cnf -days 1000;

#Generate the service-account certificate and private key:

openssl genrsa -out service-account.key 4096;
openssl req -new -key service-account.key -subj "/CN=service-accounts" -out service-account.csr;
openssl x509 -req -in service-account.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out service-account.crt -days 1000;

#Copy the appropriate certificates and private keys to each controller instance:
scp ca.crt ca.key kube-apiserver.key kube-apiserver.crt service-account.key service-account.crt etcd-server.key etcd-server.crt   master-2:~/

#https://github.com/mmumshad/kubernetes-the-hard-way/blob/master/docs/05-kubernetes-configuration-files.md
#05-kubernetes-configuration-files.md
#Kubernetes Public IP Address
#Each kubeconfig requires a Kubernetes API Server to connect to. To support high availability the IP address assigned to the load balancer will be used. In our case it is 192.168.5.30
LOADBALANCER_ADDRESS=192.168.5.30

echo "$LOADBALANCER_ADDRESS"
echo "the variable needs to be exported for the below commands to work"
echo "run the following commands to generate kuberenetes configuration files"

kubectl config set-cluster kubernetes-the-hard-way \
   --certificate-authority=ca.crt \
   --embed-certs=true \
   --server=https://${LOADBALANCER_ADDRESS}:6443 \
   --kubeconfig=kube-proxy.kubeconfig
 kubectl config set-credentials system:kube-proxy \
   --client-certificate=kube-proxy.crt \
   --client-key=kube-proxy.key \
   --embed-certs=true \
   --kubeconfig=kube-proxy.kubeconfig
 kubectl config set-context default \
   --cluster=kubernetes-the-hard-way \
   --user=system:kube-proxy \
   --kubeconfig=kube-proxy.kubeconfig
 kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
#Generate a kubeconfig file for the kube-controller-manager service:
kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.crt \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=kube-controller-manager.kubeconfig
kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=kube-controller-manager.crt \
  --client-key=kube-controller-manager.key \
  --embed-certs=true \
  --kubeconfig=kube-controller-manager.kubeconfig
kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:kube-controller-manager \
  --kubeconfig=kube-controller-manager.kubeconfig
kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
#Generate a kubeconfig file for the kube-scheduler service
 kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=kube-scheduler.crt \
    --client-key=kube-scheduler.key \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
#Generate a kubeconfig file for the admin user:
kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=admin.crt \
    --client-key=admin.key \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig

  kubectl config use-context default --kubeconfig=admin.kubeconfig

#Distribute the Kubernetes Configuration Files

for instance in worker-1 worker-2; do
  scp kube-proxy.kubeconfig ${instance}:~/
done

for instance in  master-2; do
  scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${instance}:~/
done

#06-data-encryption-keys.md

#Generate an encryption key:

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
#Create the encryption-config.yaml encryption config file:

cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
#Copy the encryption-config.yaml encryption config file to each controller instance:

for instance in master-2; do
  scp encryption-config.yaml ${instance}:~/
done

#07-bootstrapping-etcd.md

echo "#################################################"
echo " The commands in this lab must be run on each controller instance: master-1, and master-2"
echo "#################################################"

wget -q --show-progress --https-only --timestamping   "https://github.com/coreos/etcd/releases/download/v3.4.14/etcd-v3.4.14-linux-amd64.tar.gz";
tar -xvzf etcd-v3.4.14-linux-amd64.tar.gz;
sudo mv etcd-v3.4.14-linux-amd64/etcd* /usr/local/bin/;
sudo mkdir -p /etc/etcd /var/lib/etcd;  sudo cp ca.crt etcd-server.key etcd-server.crt /etc/etcd/

INTERNAL_IP=$(ip addr show enp0s8 | grep "inet " | awk '{print $2}' | cut -d / -f 1) 
ETCD_NAME=$(hostname -s)
#Create the etcd.service systemd unit file:
cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/etcd-server.crt \\
  --key-file=/etc/etcd/etcd-server.key \\
  --peer-cert-file=/etc/etcd/etcd-server.crt \\
  --peer-key-file=/etc/etcd/etcd-server.key \\
  --trusted-ca-file=/etc/etcd/ca.crt \\
  --peer-trusted-ca-file=/etc/etcd/ca.crt \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster master-1=https://192.168.5.11:2380,master-2=https://192.168.5.12:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd


echo "#################################################"
echo " All the above commands must be re-run on master-2"
echo "#################################################"

#List the etcd cluster members:
#Verify on either master-1 or master-2 or both
sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.crt \
  --cert=/etc/etcd/etcd-server.crt \
  --key=/etc/etcd/etcd-server.key

echo "both cluster master ip should be listed and status started"

#08-bootstrapping-kubernetes-controllers.md

echo "#################################################"
echo "The commands in this lab must be run on each controller instance: master-1, and master-2. Login to each controller instance using SSH Terminal."
echo "#################################################"
#Create the Kubernetes configuration directory:

sudo mkdir -p /etc/kubernetes/config

echo "##############################################################"
echo "##############################################################"
echo "run all these commands in both masters"
echo "##############################################################"
echo "##############################################################"
echo "using the latest release"
echo "CKA exam requirement is v1.18.0"

#Download the official Kubernetes release binaries:
wget -q --show-progress --https-only --timestamping \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kube-apiserver" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kube-controller-manager" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kube-scheduler" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl"
#Install the Kubernetes binaries
chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/
#Configure the Kubernetes API Server
sudo mkdir -p /var/lib/kubernetes/
sudo cp ca.crt ca.key kube-apiserver.crt kube-apiserver.key \
    service-account.key service-account.crt \
    etcd-server.key etcd-server.crt \
    encryption-config.yaml /var/lib/kubernetes/
#Retrieve the internal IP address for the current compute instance to be used to advertise for API server
INTERNAL_IP=$(ip addr show enp0s8 | grep "inet " | awk '{print $2}' | cut -d / -f 1)
echo $INTERNAL_IP
#Create the kube-apiserver.service systemd unit file:
cat <<EOF | sudo tee /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${INTERNAL_IP} \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/ca.crt \\
  --enable-admission-plugins=NodeRestriction,ServiceAccount \\
  --enable-swagger-ui=true \\
  --enable-bootstrap-token-auth=true \\
  --etcd-cafile=/var/lib/kubernetes/ca.crt \\
  --etcd-certfile=/var/lib/kubernetes/etcd-server.crt \\
  --etcd-keyfile=/var/lib/kubernetes/etcd-server.key \\
  --etcd-servers=https://192.168.5.11:2379,https://192.168.5.12:2379 \\
  --event-ttl=1h \\
  --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.crt \\
  --kubelet-client-certificate=/var/lib/kubernetes/kube-apiserver.crt \\
  --kubelet-client-key=/var/lib/kubernetes/kube-apiserver.key \\
  --kubelet-https=true \\
  --runtime-config="api/all=true" \\
  --service-account-key-file=/var/lib/kubernetes/service-account.crt \\
  --service-cluster-ip-range=10.96.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/var/lib/kubernetes/kube-apiserver.crt \\
  --tls-private-key-file=/var/lib/kubernetes/kube-apiserver.key \\
  --v=2 \
  --feature-gates="IPv6DualStack=true" \
  --feature-gates="ServiceAccountIssuerDiscovery=false" \
  --service-account-issuer=https://${INTERNAL_IP}:6443/auth/realms/master/.well-known/openid-configuration \
  --service-account-signing-key-file=/var/lib/kubernetes/service-account.key
  
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

#Copy the kube-controller-manager kubeconfig into place:
sudo cp kube-controller-manager.kubeconfig /var/lib/kubernetes/
#Create the kube-controller-manager.service systemd unit file:
cat <<EOF | sudo tee /etc/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --address=0.0.0.0 \\
  --cluster-cidr=192.168.5.0/24 \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/var/lib/kubernetes/ca.crt \\
  --cluster-signing-key-file=/var/lib/kubernetes/ca.key \\
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  --leader-elect=true \\
  --root-ca-file=/var/lib/kubernetes/ca.crt \\
  --service-account-private-key-file=/var/lib/kubernetes/service-account.key \\
  --service-cluster-ip-range=10.96.0.0/24 \\
  --use-service-account-credentials=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
#Copy the kube-scheduler kubeconfig into place:
sudo cp kube-scheduler.kubeconfig /var/lib/kubernetes/
#Create the kube-scheduler.service systemd unit file:
cat <<EOF | sudo tee /etc/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
  --kubeconfig=/var/lib/kubernetes/kube-scheduler.kubeconfig \\
  --address=127.0.0.1 \\
  --leader-elect=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
#Start the Controller Services
sudo systemctl daemon-reload
sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler
sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler
sudo systemctl status --no-pager kube-apiserver kube-controller-manager kube-scheduler

#Verification
kubectl get componentstatuses --kubeconfig admin.kubeconfig

#Provision a Network Load Balancer
echo "###############################################"
echo "###############################################"
echo "Login to loadbalancer instance using SSH Terminal."
echo "###############################################"
echo "###############################################"
#install ha-proxy
ssh loadbalancer 'sudo apt-get update && sudo apt-get install -y haproxy'

cat <<EOF | sudo tee /etc/haproxy/haproxy.cfg 
frontend kubernetes
    bind 192.168.5.30:6443
    option tcplog
    mode tcp
    default_backend kubernetes-master-nodes

backend kubernetes-master-nodes
    mode tcp
    balance roundrobin
    option tcp-check
    server master-1 192.168.5.11:6443 check fall 3 rise 2
    server master-2 192.168.5.12:6443 check fall 3 rise 2
EOF

sudo service haproxy restart
#Make a HTTP request for the Kubernetes version info:
curl  https://192.168.5.30:6443/version -k

#09-bootstrapping-kubernetes-workers.md
########################################
#In this lab you will bootstrap 2 Kubernetes worker nodes
# docker is already installed in worker nodes"
#Generate a certificate and private key for one worker node:

#On master-1
cat > openssl-worker-1.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = worker-1
IP.1 = 192.168.5.21
EOF

openssl genrsa -out worker-1.key 4096
openssl req -new -key worker-1.key -subj "/CN=system:node:worker-1/O=system:nodes" -out worker-1.csr -config openssl-worker-1.cnf
openssl x509 -req -in worker-1.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out worker-1.crt -extensions v3_req -extfile openssl-worker-1.cnf -days 1000
#Get the kub-api server load-balancer IP.

LOADBALANCER_ADDRESS=192.168.5.30
#Generate a kubeconfig file for the first worker node.
kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://${LOADBALANCER_ADDRESS}:6443 \
    --kubeconfig=worker-1.kubeconfig

  kubectl config set-credentials system:node:worker-1 \
    --client-certificate=worker-1.crt \
    --client-key=worker-1.key \
    --embed-certs=true \
    --kubeconfig=worker-1.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:worker-1 \
    --kubeconfig=worker-1.kubeconfig

  kubectl config use-context default --kubeconfig=worker-1.kubeconfig
#Copy certificates, private keys and kubeconfig files to the worker node:
scp ca.crt worker-1.crt worker-1.key worker-1.kubeconfig worker-1:~/

#On worker-1:
echo "###############################################"
echo "###############################################"
echo "Login to worker-1 instance using SSH Terminal."
echo "###############################################"
echo "###############################################"

#Download the official Kubernetes release binaries:
wget -q --show-progress --https-only --timestamping \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kube-proxy" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubelet"


#Create the installation directories:
sudo mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes
#Install the worker binaries:
chmod +x kubectl kube-proxy kubelet
sudo mv kubectl kube-proxy kubelet /usr/local/bin/

#Configure the Kubelet
sudo mv ${HOSTNAME}.key ${HOSTNAME}.crt /var/lib/kubelet/
sudo mv ${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig
sudo mv ca.crt /var/lib/kubernetes/

#Create the kubelet-config.yaml configuration file
cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.crt"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.96.0.10"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
EOF

#Create the kubelet.service systemd unit file
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --tls-cert-file=/var/lib/kubelet/${HOSTNAME}.crt \\
  --tls-private-key-file=/var/lib/kubelet/${HOSTNAME}.key \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

#Configure the Kubernetes Proxy
sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
#Create the kube-proxy-config.yaml configuration file:
cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "192.168.5.0/24"
EOF

#Create the kube-proxy.service systemd unit file
cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

#start Worker services
sudo systemctl daemon-reload
sudo systemctl enable kubelet kube-proxy
sudo systemctl start kubelet kube-proxy



echo "###############################################"
echo "###############################################"
echo "Login to master-1 instance using SSH Terminal."
echo "###############################################"
echo "###############################################"

#Verify registered node
kubectl get nodes --kubeconfig admin.kubeconfig
echo " status will not be ready as networking setup is not complete"

#10-tls-bootstrapping-kubernetes-workers.md
echo "###############################################"
echo "###############################################"
echo "run the command from the master-1"
echo "###############################################"
echo "###############################################"

scp ca.crt worker-2:~/
echo "###############################################"
echo "###############################################"
echo "run the command from the worker-2"
echo "###############################################"

#Download and Install Worker Binaries
wget -q --show-progress --https-only --timestamping \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kube-proxy" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubelet"


#Create the installation directories:
sudo mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes
#Install the worker binaries:
chmod +x kubectl kube-proxy kubelet
sudo mv kubectl kube-proxy kubelet /usr/local/bin/

#move the ca cert
sudo mv ca.crt /var/lib/kubernetes/
echo "###############################################"
echo "###############################################"
echo "run the command from the master-1"
echo "###############################################"
echo "###############################################"

#setup KUBECONFIG env variable
KUBECONFIG=admin.kubeconfig
export KUBECONFIG_SAVED=$KUBECONFIG
kubectl config view

#Step 1 Create the Boostrap Token to be used by Nodes(Kubelets) to invoke Certificate API

cat > bootstrap-token-07401b.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  # Name MUST be of form "bootstrap-token-<token id>"
  name: bootstrap-token-07401b
  namespace: kube-system

# Type MUST be 'bootstrap.kubernetes.io/token'
type: bootstrap.kubernetes.io/token
stringData:
  # Human readable description. Optional.
  description: "The default bootstrap token generated by 'kubeadm init'."

  # Token ID and secret. Required.
  token-id: 07401b
  token-secret: f395accd246ae52d

  # Expiration. Optional.
  expiration: 2022-03-10T03:22:11Z

  # Allowed usages.
  usage-bootstrap-authentication: "true"
  usage-bootstrap-signing: "true"

  # Extra groups to authenticate the token as. Must start with "system:bootstrappers:"
  auth-extra-groups: system:bootstrappers:worker
EOF

#if KUBECONFIG evn variable is not set, then you will get an error or you can point to file location
kubectl create -f bootstrap-token-07401b.yaml --kubeconfig admin.kubeconfig

#Things to note:
#	- expiration - make sure its set to a date in the future.
#	- auth-extra-groups - this is the group the worker nodes are part of. It must start with "system:bootstrappers:" This group does not exist already. This group is associated with this token.
#	- Once this is created the token to be used for authentication is 07401b.f395accd246ae52d

#Step 2 Authorize workers(kubelets) to create CSR
cat > csrs-for-bootstrapping.yaml <<EOF
# enable bootstrapping nodes to create CSR
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: create-csrs-for-bootstrapping
subjects:
- kind: Group
  name: system:bootstrappers
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: system:node-bootstrapper
  apiGroup: rbac.authorization.k8s.io
EOF
kubectl create -f csrs-for-bootstrapping.yaml --kubeconfig admin.kubeconfig

#Step 2: Authorize workers to approve csr
kubectl create clusterrolebinding auto-approve-csrs-for-group --clusterrole=system:certificates.k8s.io:certificatesigningrequests:nodeclient --group=system:bootstrappers --kubeconfig admin.kubeconfig

#Step 3: Step 3 Authorize workers(kubelets) to Auto Renew Certificates on expiration
kubectl create clusterrolebinding auto-approve-renewals-for-nodes --clusterrole=system:certificates.k8s.io:certificatesigningrequests:selfnodeclient --group=system:nodes  --kubeconfig admin.kubeconfig

#Step 4 Configure Kubelet to TLS Bootstrap

echo "###############################################"
echo "###############################################"
echo "run the command from the worker-2"
echo "###############################################"
echo "###############################################"



sudo kubectl config --kubeconfig=/var/lib/kubelet/bootstrap-kubeconfig set-cluster bootstrap --server='https://192.168.5.30:6443' --certificate-authority=/var/lib/kubernetes/ca.crt
sudo kubectl config --kubeconfig=/var/lib/kubelet/bootstrap-kubeconfig set-credentials kubelet-bootstrap --token=07401b.f395accd246ae52d
sudo kubectl config --kubeconfig=/var/lib/kubelet/bootstrap-kubeconfig set-context bootstrap --user=kubelet-bootstrap --cluster=bootstrap
sudo kubectl config --kubeconfig=/var/lib/kubelet/bootstrap-kubeconfig use-context bootstrap



#Step 5 Create Kubelet Config File
#
Create the kubelet-config.yaml configuration file:

cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.crt"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.96.0.10"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
EOF

#Step 5 Create Kubelet Config File

#Create the kubelet-config.yaml configuration file:

cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.crt"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.96.0.10"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
EOF

#Step 6 Configure Kubelet Service
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --bootstrap-kubeconfig="/var/lib/kubelet/bootstrap-kubeconfig" \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --cert-dir=/var/lib/kubelet/pki/ \\
  --rotate-certificates=true \\
  --rotate-server-certificates=true \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

#Step 7 Configure the Kubernetes Proxy
ls /var/lib/kube-proxy/kubeconfig
#(file needs to be present , which was previously copied)

#Create the kube-proxy-config.yaml configuration file:

cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "192.168.5.0/24"
EOF
#Create the kube-proxy.service systemd unit file:

cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

#Step 8 Start the Worker Services
sudo systemctl daemon-reload
sudo systemctl enable kubelet kube-proxy
sudo systemctl start kubelet kube-proxy
systemctl status --no-pager kubelet kube-proxy


#Step 9 Approve Server CSR
kubectl get csr #not working