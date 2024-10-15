docker: 
	./scripts/prepare-cloud-img.sh
	./scripts/launch-virtual-machine.sh -c ./configs/docker.ini
	./scripts/verify-deployment.sh -c ./configs/docker.ini | tail -n1 > ./creds/docker.ssh
	chmod u+x ./creds/docker.ssh
	echo "sudo apt-get update" | ./creds/docker.ssh
	curl https://billthewizard.net/_static/install_docker.sh | ./creds/docker.ssh
	echo "default VM deployed and ready for configuration."

default:
	./scripts/prepare-cloud-img.sh
	./scripts/launch-virtual-machine.sh -c ./configs/default.ini
	./scripts/verify-deployment.sh -c ./configs/default.ini | tail -n1 > ./creds/default.ssh
	chmod u+x ./creds/default.ssh
	echo "default VM deployed and ready for configuration."

clean_default:
	./scripts/cleanup.sh -c ./configs/default.ini
	rm -f ./creds/default.ssh

clean_docker:
	./scripts/cleanup.sh -c ./configs/docker.ini

test:
	make default
	make clean_default
