docker: 
	./vmctl launch docker
	echo "Docker VM deployed and ready for configuration."

default:
	./vmctl launch default
	echo "default VM deployed and ready for configuration."

clean_default:
	./scripts/cleanup.sh -c ./conf.d/default.conf

clean_docker:
	./scripts/cleanup.sh -c ./conf.d/docker.conf

prepare_cloud_img:
	./scripts/prepare-cloud-img.sh

test:
	make default
	make clean_default
