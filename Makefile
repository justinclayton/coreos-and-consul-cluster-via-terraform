default: packages deploy

deploy: plan terraform
	terraform apply -input=false < plan

plan: templates terraform
	terraform plan -input=false -out plan

templates: leader-cloud-config.yml follower-cloud-config.yml

leader-cloud-config.yml: discovery_url
	cat templates/leader-cloud-config.yml.template | sed -e "s#{{ discovery_url }}#`cat discovery_url`#" > leader-cloud-config.yml

follower-cloud-config.yml: discovery_url
	cat templates/follower-cloud-config.yml.template | sed -e "s#{{ discovery_url }}#`cat discovery_url`#" > follower-cloud-config.yml

discovery_url:
	curl -s https://discovery.etcd.io/new > discovery_url

destroy: terraform
	terraform destroy -input=false

clean:
	rm -f plan
	rm -f discovery_url
	rm -f leader-cloud-config.yml
	rm -f follower-cloud-config.yml

clean-all: destroy clean
	rm -f terraform.tfstate
	rm -f terraform.tfstate.backup

packages: /usr/local/bin/fleetctl /usr/local/bin/terraform

fleetctl: /usr/local/bin/fleetctl

/usr/local/bin/fleetctl:
	brew install fleetctl

terraform: /usr/local/bin/terraform

/usr/local/bin/terraform:
	brew install terraform