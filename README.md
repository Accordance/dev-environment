Accordance Development environment
==================================

Starting the Environment
------------------------
1. Make sure that your environment is prepared per the 'Initial Setup' instructions
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
1. Make sure you have all the 'Prerequisites'
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

Prerequisites
--------------
1. Ruby >= 2.1.2
1. RVM >= 1.26.9
1. Docker (should be 100% operational)
1. boot2docker >= 1.6.0 (if you're on Mac)
   * VirtualBox >= 4.3.26
