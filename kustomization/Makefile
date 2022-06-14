
RELEASE_NAME ?= dev

activemq:
	helm template activemq-$(RELEASE_NAME) ../helm/activemq -f ../helm/activemq/values.yaml -f ../helm/activemq/values-lsst.yaml > activemq.yaml

idds:
	# helm template idds-$(RELEASE_NAME) ../helm/idds -f ../helm/idds/values.yaml -f ../helm/idds/values-lsst.yaml -f ../helm/idds/values-secret.yaml > idds.yaml
	helm template idds-$(RELEASE_NAME) ../helm/idds -f ../helm/idds/values.yaml -f ../helm/idds/values-lsst.yaml > idds.yaml

panda:
	# helm template panda-$(RELEASE_NAME) ../helm/panda -f ../helm/panda/values.yaml -f ../helm/panda/values-lsst.yaml -f ../helm/panda/values-secret.yaml> panda.yaml
	helm template panda-$(RELEASE_NAME) ../helm/panda -f ../helm/panda/values.yaml -f ../helm/panda/values-lsst.yaml > panda.yaml

helm: activemq idds panda

apply:
	kubectl apply -k .
