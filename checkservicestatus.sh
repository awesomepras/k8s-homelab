#!/bin/sh
echo "Check etcd server is up"
echo "run it on master-1"
sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.crt \
  --cert=/etc/etcd/etcd-server.crt \
  --key=/etc/etcd/etcd-server.key
echo "check all services are up and running"
sudo systemctl status kube-apiserver kube-controller-manager kube-scheduler|egrep "Kubernetes|Active"
echo "check the controlplane status on master-1"
kubectl get componentstatuses --kubeconfig admin.kubeconfig
echo "check the node status"
kubectl get nodes --kubeconfig admin.kubeconfig

echo "check if loadbalancer node is up and reachable"
curl  https://192.168.5.30:6443/version -k
