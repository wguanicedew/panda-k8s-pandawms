PanDA System Kuberneters Deployment
===================================

Main Components
---------------
* PanDA: Workload manager, manages/schedules tasks and jobs.

  * panda-server
  * panda-JEDI
  * panda-database (postgresql)

* Harvester: Resource facing service to submit pilots to Grid/Cloud.

  * Harvester
  * Harvester-db (mariadb)

* iDDS: Workflow manager, manages the dependencies of tasks and jobs.

  * rest
  * daemon
  * database (postgresql)

* bigmon: panda monitor

* activemq: messaging service

* IAM: OIDC authentication service

  * indigo-iam-login_service
  * database (mariadb)

Deployment order
-----------------
* PanDA, Harvester and iDDS depend on activemq.
* PanDA, Harvester, iDDS and bigmon depend on IAM.
* Harvester, iDDS and BigMon need to communicate with PanDA.
* So the installation order is

  * activemq, IAM
  * PanDA
  * Harvester, iDDS, BigMon

Deployment info
-----------------

There are different installations:

  * Secret installation: In this installation, secret information are kept in *secrets/<service>*. You need to keep the secret file in a diferent place (such as applying *helm secrets*). For the secret deployment, you can keep them for long time and only update it when it's needed. After deploying the secrets, you can deploy the service.

  * Experiment based installation: For different experiments, there maybe special requirements, for example different namespaces or different persistent volumens. In this case, an experiment specific file *values-<experiment>.yaml* is required.

  * *In the example, secrets are kept in the same location as service files. For a production instance, it's good to encrypt them or put them in a different location.*

Deployment with secrets
------------------------

* Deploy secrets. The secrets files can be kept in a private repository or use 'helm secrets' to encrypt them. Different experiments many have different solutions to keep the secrets. Here we separate the secrets part because we can keep them for long time after they are deployed. The updating frequence for secrets can be much less than updating the instance.

Deploy secrets:
+++++++++++++++

The secrets can be stored in a private repository or in the same repository but encrypted. They can be deployed one time and then used for long term (*Please set the values correctly in the secrets/<>/values.yaml*)::

  $> helm install activemq-dev-secret  secrets/msgsvc/
  $> helm install iam-dev-secret secrets/iam/
  $> helm install panda-dev-secret secrets/panda/
  $> helm install idds-dev-secret secrets/idds
  $> helm install harvester-dev-secret secrets/harvester/
  $> (bigmon to be done)

Deploy the instances:
+++++++++++++++++++++

When the secrets are deployed. Someone else or some daemons can automatically deploy the panda instances.

* Deploy ActiveMQ::

  $> helm install activemq-dev helm/msgsvc/ -f helm/msgsvc/values.yaml -f helm/msgsvc/values/values-use-secret.yaml

* Deploy IAM::

  $> helm install iam-dev helm/iam -f helm/iam/values.yaml -f helm/iam/values/values-use-secret.yaml

* Deploy PanDA::

  $> helm install panda-dev helm/panda/ -f helm/panda/values.yaml -f helm/panda/values/values-use-secret.yaml

* Deploy iDDS::

  $> helm install idds-dev helm/idds/ -f helm/idds/values.yaml -f helm/idds/values/values-use-secret.yaml

* Deploy Harvester::

  $> helm install harvester-dev helm/harvester/ -f helm/harvester/values.yaml  -f helm/harvester/values/values-use-secret.yaml

* Deploy BigMon (tobedone)::

  $> helm install bigmon-dev helm/bigmon

LSST deployment
-----------------

For LSST deployment (at SLAC), the persistent volume is 'wekafs--sdf-k8s01'.

*NOTE: values-use-secret.yaml will overwrite some values in values-lsst.yaml. So the order of value files is important*

* Deploy ActiveMQ::

  $> helm install activemq-dev helm/msgsvc/ -f helm/msgsvc/values.yaml -f helm/msgsvc/values/values-lsst.yaml -f helm/msgsvc/values/values-use-secret.yaml

* Deploy IAM::

  $> helm install iam-dev helm/iam -f helm/iam/values.yaml -f helm/iam/values/values-lsst.yaml -f helm/iam/values/values-use-secret.yaml

* Deploy PanDA::

  $> helm install panda-dev helm/panda/ -f helm/panda/values.yaml -f helm/panda/values/values-lsst.yaml -f helm/panda/values/values-use-secret.yaml

* Deploy iDDS::

  $> helm install idds-dev helm/idds/ -f helm/idds/values.yaml -f helm/idds/values/values-lsst.yaml -f helm/idds/values/values-use-secret.yaml

* Deploy Harvester::

  $> helm install harvester-dev helm/harvester/ -f helm/harvester/values.yaml -f helm/harvester/values/values-lsst.yaml -f helm/harvester/values/values-use-secret.yaml

* Deploy BigMon (tobedone)::

  $> helm install bigmon-dev helm/bigmon


Sphenix deployment
------------------

For Sphenix deployment (at BNL), the persistent volume is 'nas'.

*NOTE: values-use-secret.yaml will overwrite some values in values-sphenix.yaml. So the order of value files is important*

* Deploy ActiveMQ::

  $> helm install activemq-dev helm/msgsvc/ -f helm/msgsvc/values.yaml -f helm/msgsvc/values/values-sphenix.yaml -f helm/msgsvc/values/values-use-secret.yaml

* Deploy IAM::

  $> helm install iam-dev helm/iam -f helm/iam/values.yaml -f helm/iam/values/values-sphenix.yaml -f helm/iam/values/values-use-secret.yaml

* Deploy PanDA::

  $> helm install panda-dev helm/panda/ -f helm/panda/values.yaml -f helm/panda/values/values-sphenix.yaml -f helm/panda/values/values-use-secret.yaml

* Deploy iDDS::

  $> helm install idds-dev helm/idds/ -f helm/idds/values.yaml -f helm/idds/values/values-sphenix.yaml -f helm/idds/values/values-use-secret.yaml

* Deploy Harvester::

  $> helm install harvester-dev helm/harvester/ -f helm/harvester/values.yaml -f helm/harvester/values/values-sphenix.yaml -f helm/harvester/values/values-use-secret.yaml

* Deploy BigMon (tobedone)::

  $> helm install bigmon-dev helm/bigmon
