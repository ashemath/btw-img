default: 
	./scripts/prepare-cloud-img.sh
	mkdir ./creds
	./scripts/launch-virtual-machine.sh -c default.ini | tail -n1 > ./creds/default.ssh
	chmod u+x ./creds/default.ssh
	echo "sudo apt-get update" | ./creds/default.ssh
	curl https://billthewizard.net/_static/install_docker.sh | ./creds/default.ssh
	echo "default VM deployed and ready for configuration."
clean_default:
	./scripts/cleanup.sh -c default.ini

test:
	make default
	make clean_default
