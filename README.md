#btw-img
System deployment and configuration tools by Bill the Wizard

## Status: Needs Makefile...
There are three crucial scripts:
scripts/prepare-cloud-img.sh: Download and prepare for install the latest
    Debian12 Generic Cloud image
scripts/launch-virtual-machine.sh: Launch a Virtual machine based on the contents
    of a .ini file. `./scripts/launch-virtual-machine.sh -c default.ini`
scripts/cleanup.sh: Cleanup the files and configuration associated with an ini file
    `./script/cleanup -c default.ini`

## What next?
Maybe try to install the docker engine:
```
sh -c "$(curl https://billthewizard.net/_static/install_docker.sh)"

```
