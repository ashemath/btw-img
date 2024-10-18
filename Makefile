docker: 
	./scripts/prepare-cloud-img.sh
	./scripts/launch-virtual-machine.sh -c ./conf.d/docker.conf
	./scripts/verify-deployment.sh -c ./conf.d/docker.conf | tail -n1 > ./creds/docker.ssh
	chmod u+x ./creds/docker.ssh
	echo "sudo apt-get update" | ./creds/docker.ssh
	curl https://billthewizard.net/_static/install_docker.sh | ./creds/docker.ssh
	echo "Docker VM deployed and ready for configuration."

default:
	./scripts/prepare-cloud-img.sh
	./scripts/launch-virtual-machine.sh -c ./conf.d/default.conf
	./scripts/verify-deployment.sh -c ./conf.d/default.conf | tail -n1 > ./creds/default.ssh
	chmod u+x ./creds/default.ssh
	echo "default VM deployed and ready for configuration."

clean_default:
	./scripts/cleanup.sh -c ./conf.d/default.conf
	rm -f ./creds/default.ssh

clean_docker:
	./scripts/cleanup.sh -c ./conf.d/docker.conf

prepare_cloud_img:
	./scripts/prepare-cloud-img.sh

test:
	make default
	make clean_default
