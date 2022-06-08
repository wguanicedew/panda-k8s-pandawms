# iDDS k8s

## helm installation

(1) create token file to authorize the connection from iDDS to PanDA "helm/idds/charts/daemon/idds2panda_token". It can be setup with "https://github.com/HSF/iDDS/blob/master/doma/bin/setup_panda_token".

(2) create secret file "helm/idds/values-secret.yaml" from "helm/idds/values-secret.yaml.template"

(3) install iDDS
helm install -n panda --values ./helm/idds/values-secret.yaml idds-dev helm/idds

(3.1) install iDDS for SLAC
helm install -n panda --values ./helm/idds/values-secret.yaml --values ./helm/idds/values-lsst.yaml idds-dev helm/idds/
