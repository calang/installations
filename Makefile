# Description

# variable definitions, available to all rules
# REPO_ROOT := $(shell git rev-parse --show-toplevel)  # root directory of this git repo
# BRANCH := $(shell git branch --show-current)
# BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
# Notes:
# all env variables are available
# = uses recursive substitution
# :=  uses immediate substitution
GPU_ENV := nvidia_gpu_setup


# === standard targets ===


# target: help - Display callable targets.
help:
	@echo "Usage:  make <target>"
	@echo "  where <target> may be"
	@echo
	@egrep -h "^# target:" [Mm]akefile | sed -e 's/^# target: //'



# === package installation and configuration - when possible ===


# Postman
# Orange
# Knime
# kdif3
# tomplay
# musescore
# pandoc
# VS Code
# dconf-editor
# Slack
# discourse
# R
# rStudio Desktop
# rStudio Server


# target run-all: run all the installation scripts
run-all:
	scripts/run-all.sh


# target: adduser - add earth user, if not already created
adduser:
	sudo scripts/adduser.sh

# target: alias - create alias definitions for bash start-up
alias:
	scripts/alias.sh

# target: chrome - install chrome
chrome:
	sudo scripts/install-chrome.sh

# target: conda - install conda (mamba)
conda:	mamba

# # target: clasp - install clasp: ASP resolution
# # not effective to enable multi-threading
# clasp:
# 	sudo scripts/install-clasp.sh

# # target: clingo - install clingo: ASP resolution
# # not effective to enable multi-threading, yet (need official version of clingo for actual ubuntu version)
# clingo:
# 	sudo scripts/install-clingo.sh

# target: docker-ce - install docker community edition (docker engine)
docker-ce:
	sudo scripts/install-docker-ce.sh

# target: docker-desk - install docker desktop
docker-desk:
	sudo scripts/install-docker-desk.sh
	# sudo scripts/install-docker-desk.sh && sudo scripts/dd-service.sh

# target: nodocker-desk - uninstall docker desktop
nodocker-desk:
	sudo scripts/nodocker-desk.sh

# target: drawio - install drawio
drawio:
	sudo snap install drawio
	cp -r "compendium discussion icons" ../installed

# target: freeling - install FreeLing: free linguistic analyses
freeling:
	sudo scripts/install-freeling.sh

# target: fuse - install fuse, "F"ilesystem in Userspace"
fuse:
	apt list fuse || sudo apt-get install -y libfuse2

# target: gaudi - install gaudi, agente firmador de firma digital BCCR
gaudi:	java
	cd scripts/sfd_ClientesLinux_DEB64_Rev26; sudo ./instalacion.sh

# target: git - install git
git:
	sudo scripts/install-git.sh

# target: git-user - adjust git to user
git-user:	git
	scripts/adj-git.sh

# target: gimp - install gimp
gimp:
	sudo apt install -y gimp

# target: gnuplot - 
gnuplot:
	sudo scripts/install-gnuplot.sh

# target: gpu - fix links to nvidia gpu libraries
gpu:	gpu-env
	sudo scripts/gpu.sh $(GPU_ENV)

# target: gpu-env - create conda env for gpu target
gpu-env:	conda scripts/environment.yml
	scripts/gpu-env.sh $(GPU_ENV)

# target: graphviz - install graphviz
graphviz:
	sudo scripts/install-graphviz.sh

# target: gtcolors - adjust bash gnome terminal colors
gtcolors:
	scripts/adj-gtcolors.sh

# target imagepreviews - enable showing image previews on File / Desktop interface
imagepreviews:
	sudo scripts/enable-imagepreviews.sh

# target: intellij - idea
intellij:
	sudo scripts/install-intellij.sh
	
# target: janus - install library(janus): a package to call Python from SWI-Prolog
janus:	python swi-prolog
	sudo apt install -y libpython3-dev

# target: java - install java
java:
	sudo apt install -y default-jre

# target: jupl - install jupyterlab in mamba base environment
jupl:	mamba
	scripts/install-jupl.sh
	
# target: jupl-swi - install jupyter lab kernel for SWI-Prolog
jupl-swi:	mamba jupl swi-prolog
	scripts/install-jupl-swi.sh

# target: libreoffice - install LibreOffice suite
libreoffice:
	sudo scripts/install-libreoffice.sh

# target: librejava - install Java integration with LibreOffice
librejava:	libreoffice
	sudo apt install -y libreoffice-java-common

# target: librepython - install Python integration with LibreOffice (UNO bridge)
librepython:	libreoffice python
	sudo apt install -y python3-uno libreoffice-script-provider-python

# target: mamba - install mamba
mamba:
	# per-user installation
	which conda || scripts/install-mamba.sh

# target musescore - install musescore, using FUSE
musescore:	fuse screen
	scripts/install-musescore.sh

# target: music_dep - install abcmidi and timidity
music_dep:
	sudo apt-get install abcmidi timidity

# target: pgadmin - GUI to manage PostgreSQL DBs
pgadmin:
	sudo scripts/install-pgadmin.sh

# target: postgres - install PostgreSQL
postgres:
	scripts/install-postgres.sh

# target: prompt - adjust bash prompt
prompt:
	scripts/adj-prompt.sh

# target: pycharm - install pycharm
pycharm:
	sudo snap install pycharm-community --classic

# target: python - apply system-wide python adjustments
python:
	sudo scripts/adj-python.sh
	
# target: subl - install Sublime Text editor
subl:
	sudo scripts/install-subl.sh

# target: swi-prolog - install swi-prolog
swi-prolog:
	which swipl || sudo scripts/install-swi-prolog.sh

# unsuccessful installation:
# # target: plplot - optional swi-prolog package
# plplot:	gnuplot
# 	sudo scripts/install-plplot.sh

# target: prolog_graphviz - optional swi-prolog package
prolog_graphviz:	swi-prolog
	swipl -g 'pack_install(prolog_graphviz)' -t halt

# target: scasp - binary executable for scasp
scasp:
	scripts/install-scasp.sh

# target: screen - install screen: a sub-shell to replicate the terminal environment
screen:
	sudo apt install -y screen

# target: unixodbc - ODBC solution for UNIX/Linux
unixodbc:
	sudo scripts/install-unixodbc.sh

# target: virtualbox - install Oracle VirtualBox
virtualbox:
	sudo scripts/install-virtualbox.sh

# target: vscode - install VS Code
vscode:
	sudo scripts/install-vscode.sh

# # target: sw-xtras - Ubuntu complementary packages, like 3-rd party
# sw-xtras:
# 	sudo scripts/sw-xtras.sh

# target: win11vb-cinde - install VirtualBox Windows 11 VB for Cinde
win11vb-cinde:
	@echo 'Installing Windows 11 VirtualBox for Cinde - make sure you have the license to use Windows 11'
	@echo '*** This is disabled, for licensing reasons - enable it if you have the license ***'
	#scripts/install-win11vb-cinde.sh

# target: xdot - install xdot.py: interactive viewer for graphs written in Graphviz's dot language
xdot:
	sudo scripts/install-xdot.sh

# target: yed - install yEd Graph editor
yed:
	scripts/install-yed.sh

# target: zim - install zim
zim:
	sudo scripts/install-zim.sh

# target: zim-xtras - install packages that complement zim 
zim-xtras:	zim git graphviz
	sudo scripts/install-zim-xtras.sh

# target: zoom - install zoom
zoom:
	sudo scripts/install-zoom.sh


# === package removal ===


# target: nothunderbird - remove thunderbird email
nothunderbird:
	sudo scripts/nothunderbird.sh

# target: nodockerdesk - remove docker-desktop
nodockerdesk:
	sudo scripts/nodocker-desk.sh



# === targets waiting for a fully automated solution ===


# # target: set-mouse - set mouse buttons
# set-mouse:
# 	@echo 'Set this manually - no good script option found'
# 	# Set right mouse button as primary (1) and left button as secondary (3)
# 	# device_id=$(xinput list | grep Logitech | awk -F'id=' '{print $2}' | awk '{print $1}')
# 	# xinput set-button-map "$device_id" 3 2 1


# # target: subl-default - set Sublime Text editor as default for most text and source files
# subl-default:
# 	@echo
# 	@echo 'Set this manually - no good script option found'
# 	@echo
# 	@echo "- Open Nautilus (Files)"
# 	@echo "- point to a file of the desired type"
# 	@echo "- right-click,  select 'Open with'"
# 	@echo "- select sublime_text"
# 	@echo "- enable 'use this program for all such files'"
# 	@echo "- open the file"
# 	@echo


# target push - sample docker image push, asking for passwords
# push: TEMPUSR := $(shell mktemp)
# push: REGISTRY := XXX
# push:
#	@$$SHELL -i -c 'read -p "username: " user;  echo -n $${user} >$(TEMPUSR)'
#	@$$SHELL -i -c 'read -s -p "password: " user;  echo -n $${user} >$(TEMPUSR)1'
#	@docker login -u $$(cat $(TEMPUSR)) -p $$(cat $(TEMPUSR)1) $(REGISTRY)
#	@rm $(TEMPUSR)*
#	docker image push ${APP_IMAGE}


# ignore files with any of these names
# so that the rules with those as target are always executed
.PHONY: ALWAYS

# always do/refresh ALWAYS target
ALWAYS:
