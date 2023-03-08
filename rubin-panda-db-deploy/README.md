
This repo is a copy of the USDF butler Postgres infrastructure kubernetes manifests, 
modified to hold the Rubin USDF PanDA & iDDS Postgres infrastructure kubernetes manifests.

We use the [cloudnative-pg operator](https://cloudnative-pg.io/) in order to support a managed postgres service on our own infrastructure.

We need different kustomize overlays to present the postgres environments. For lack of imagination, we currently have a `prod` and `dev` environment.

# Deployment

As we are reliant on kubernetes for the infrastructure, we assume that you already have a suitable KUBECONFIG configured.

Deployment comes in two parts:

## Deploy the CNPG Operator

The cnpg operator will install into `cnpg-system` namespace.

```
CNPG_VERSION=1.18 CNPG_VERSION_MINOR=1 make update-cnpg-operator
make apply-cnpg-operator
```

In the above, we define through environment variables the version of the operator we wish to install/update. This will literally fetch the manifest and dump the contents into `cnpg-operator.yaml`. `make apply-cnpg-operator` will then use kustomize to apply that manifest onto kubernets to install the operator.

Note that in order to hep revision control our operator deployment, we also commit/push changes for the `cnpg-operator.yaml`.

## Deploy the appropriate overlay

### Deploy PanDA

For PanDA, the main database and the archive database are in the same database with different schema.

```
cd overlays/panda/$ENVIRONMENT
make apply
```

### Deploy iDDS

For iDDS, the main database and the archive database can be different databases. The archive database may need much bigger storages (depending on how long we want to keep the history data), however the performance requirement is not critical.

```
cd overlays/idds/$ENVIRONMENT/main
make apply

cd overlays/idds/$ENVIRONMENT/{main|archive}
make apply
```

# Common Tasks

Requires installation of the cnpg [kubectl plugin](https://cloudnative-pg.io/documentation/1.17/cnpg-plugin/#cloudnativepg-plugin)

### Get status of cluster

```
kubectl cnpg status usdf-panda-server -n panda-db
```

### Promote a replica to primary

```
kubectl cnpg promote usdf-panda-server -n panda-db
```

### Destroy an instance

```
kubectl cnpg destroy usdf-panda-server 1 -n panda-db
```

where 1 is the ordinal number of the instance
