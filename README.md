Accordance Dev Seed demo environment
====================================

Note: This has been tested only on MacOS

1. Clone the repo
1. Clone data-source repo in the same folder as this one
1. Make sure you have ```docker``` configured (if on Mac - boot2docker)
1. Note: on non-Mac environment set the DOCKERHOST variable to the docker0 interface IP
1. ```./start.sh```
1. Navigate to ```http://dockerhost:8000```

Accordance Development environment Step-by-Step
===============================================

Starting the Environment
------------------------
1. Make sure that your environment is prepared per the '[Initial Setup](#initial-setup)' instructions
1. Start all the components: ```rake start```
1. Wait a little for the process to complete ...
1. (Only for demo purposes) Load demo data: ```rake orientdb:init```
1. Open a browser and navigate to: http://dockerhost:8000

Environment Components
----------------------
1. Service catalog: http://dockerhost:8500
1. Graph DB (OrientDB - root/password): http://dockerhost:2480
1. Atlas service: http://dockehost:8080

Destroying the Environment
--------------------------
1. Stop all the services: ```rake stop```

Initial Setup
-------------
1. Make sure you have all the '[Prerequisites](#prerequisites)'
1. Prepare you '[Development Environment configuration](#development-environment-configuration)' by choosing steps from a section appropriate to your OS
1. Create docker machine following docker-machine instructions. Ex: ```docker-machine create --driver virtualbox dev```
1. Stop docker machine. Ex: ```docker-machine stop dev```
1. Map ports and mount folders (has to be executed once per new Docker Machine) to configure VirtualBox:
  1. Windows: run `config_docker_machine.ps1` in PowerShell
  1. MaxOS: `config_docker_machine.sh`
1. Start docker machine. Ex: ```docker-machine start dev```
1. Run `bundle install`
1. Configure 'dockerhost' hostname to be pointing to the same IP as DOCKER_HOST environment variable and it's pingable: ```ping dockerhost```
1. Create a working folder for Accordance project: ```mkdir accordance```
1. Navigate to the working folder: ```cd accordance```
1. Clone development environment repository:
   ```
   git clone https://github.com/Accordance/dev-environment.git
   cd dev-environment
   bundle install
   cd ..
   ```
1. Clone data source repository:
   ```
   git clone https://github.com/Accordance/data-source.git
   cd data-source
   bundle install
   cd ..
   ```
1. Clone service catalog repository:
   ```
   git clone https://github.com/Accordance/docker-consul-acl.git
   ```
1. Build the environment:
   ```
   cd dev-environment
   rake prepare:secrets
   ```

Configuring VirtualBox
----------------------
Set $Env:DOCKER_MACHINE_NAME variable to the name of the Docker Machine you're using
Run 'config_docker_machine' to configure VirtualBox ports and shared folders

Prerequisites
--------------

For All:
1. Ruby >= 2.1.2
1. Bundler gem (run `gem install bundle`)
1. RVM >= 1.26.9
1. (Windows/MacOS) Docker Toolbox (should be 100% operational)

For Windows:
1. Use PowerShell as default shell
1. Install [Ruby for Windows](http://rubyinstaller.org/downloads)
1. install [Ruby Development Kit](http://rubyinstaller.org/downloads) following [directions](https://github.com/oneclick/rubyinstaller/wiki/Development-Kit).
1. Follow Docker Toolbox for Windows [instructions](https://docs.docker.com/windows/step_one/).
1. Git [for Windows](http://www.git-scm.com/download/win).

Development Environment configuration
=====================================
Git
---
Configure Git on Windows to properly handle line endings
```git config --global core.autocrlf true```
Fixing "old mode" to "new mode" error on Windows
```git config core.filemode false```

For Windows
-----------
Configure environment variables by running
```config_dev_env.ps1```
