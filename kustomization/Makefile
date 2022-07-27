RELEASE_NAME ?= dev

msgsvc:
	helm template msgsvc-$(RELEASE_NAME) ../helm/msgsvc -f ../helm/msgsvc/values.yaml -f ../helm/msgsvc/values/values-lsst.yaml > msgsvc.yaml

iam:
	helm template iam-$(RELEASE_NAME) ../helm/iam -f ../helm/iam/values.yaml -f ../helm/iam/values/values-lsst.yaml > iam.yaml

idds:
	helm template idds-$(RELEASE_NAME) ../helm/idds -f ../helm/idds/values.yaml -f ../helm/idds/values/values-lsst.yaml > idds.yaml

panda:
	helm template panda-$(RELEASE_NAME) ../helm/panda -f ../helm/panda/values.yaml -f ../helm/panda/values/values-lsst.yaml > panda.yaml

harvester:
	helm template harvester-$(RELEASE_NAME) ../helm/harvester -f ../helm/harvester/values.yaml -f ../helm/harvester/values/values-lsst.yaml > harvester.yaml

bigmon:
	helm template bigmon-$(RELEASE_NAME) ../helm/bigmon -f ../helm/bigmon/values.yaml -f ../helm/bigmon/values-lsst.yaml > bigmon.yaml

helm: msgsvc iam idds panda harvester bigmon

apply:
	kubectl apply -k .
