# Kops
```sh
export KOPS_STATE_STORE=s3://kinetic-kops-state

kops toolbox template --template cluster.tmpl.yaml \
--template worker.tmpl.yaml \
--template master.tmpl.yaml --values values.yaml > output.yaml

kops create -f output.yaml
kops create secret --name kops-test.k8s.local sshpublickey admin -i ~/.ssh/id_rsa.pub
kops update cluster kops-test.k8s.local --yes
```
