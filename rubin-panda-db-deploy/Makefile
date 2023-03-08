
CNPG_VERSION ?= 1.18
CNPG_VERSION_MINOR ?= 1

update-cnpg-operator:
	curl -L https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-$(CNPG_VERSION)/releases/cnpg-$(CNPG_VERSION).$(CNPG_VERSION_MINOR).yaml > cnpg-operator.yaml

apply-cnpg-operator:
	kubectl apply -f cnpg-operator.yaml

cnpg-operator: update-cnpg-operator apply-cnpg-operator

run-apply:
	kubectl apply -k .

apply: run-apply
