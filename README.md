# Dock'ter L4T - Builds Tegra Image from Scratch!  

Its as easy as [Getting Dockter-L4T Image](#Build-the-Dockerized-Yocto-for-Jetson), [Running Dockter-L4T](#Run-the-Docker-Container-to-Build-L4T-Image), and [Flashing the SD Card](#Flash-the-SD-Card)!  
<sub>With the caviot that **_maybe_** you'll need to [install docker](#Install-Docker) if you don't already have it</sub>  


## Important Preambles

The defaults (if no overriding build arguments are supplied) are set to build a **tested and working** ["demo-image-full" image](https://github.com/OE4T/meta-tegra) for the ["jetson-nano-2gb-devkit" machine](https://developer.nvidia.com/embedded/learn/get-started-jetson-nano-2gb-devkit) which ment setting the nVidia SDK installation's targetted machine to `P3448-0003`.  
This is done my defaulting the ["tegrademo" distro](https://github.com/OE4T/tegra-demo-distro) and checking out the confirmed working commit hash of ["c4ef10f44d92ac9f1e4725178ab0cefd9add8126"](https://github.com/OE4T/tegra-demo-distro/tree/c4ef10f44d92ac9f1e4725178ab0cefd9add8126).  

**By running this docker, you are accepting [nVidia's SDK License](https://docs.nvidia.com/sdk-manager/eula/index.html).**

_Need Docker?_ There's a [quick install guide](#Install-Docker) provided below.

## Build the Dockerized Yocto for Jetson

<sub>**Info:** Executing the `entrypoint.sh` outside of the Docker container will fail. It is a script which runs automatically by and inside the docker container itself.</sub>  

* Run the following to build the docker image with the default configuration:  
`docker build -t calebprovost/dockter-l4t:latest .` Or pull it from docker hub: `docker pull calebprovost/dockter-l4t`  

    If you'd like to override the default branch, machine, target distro, or other settings, you can do so by overwriting their values with the argument tag `--build-arg VAR=value`. Below is an example provided to demonstrate this. See the file `env.list` for defaults and overwritable variables.  

    ```shell
    docker build -t calebprovost/dockter-l4t:latest \
        --build-arg MACHINE=jetson-nano-2gb-devkit \
        --build-arg BRANCH=master \
        --build-arg BUILD_IMAGE=demo-image-full \
        --build-arg DISTRO="tegrademo-mender build-tegrademo-mender" \
        $(pwd)
    ```

## Run the Docker Container to Build L4T Image  

Start the Docker container with the command below and it will kick off an installation of nVidia's SDK and build the L4T yocto image.  
You will be prompted to follow the link and log into the nVidia developer's account which will then validate the install.  
Note: The following example maps the build output directory to the directory where this Dockerfile is executed  

`docker run -it -v $PWD:/home/user/build --name dl4t --env-file ./env.list calebprovost/dockter-l4t:latest`

## Flash the SD Card

The SD Card image is created using the L4T SD Card tools and placed in the root of this directory. It's name follows the convention "${BUILD_IMAGE}-${MACHINE}.img".  

Use your flavor of SD Card flashing tool (like balenaEtcher for Windows or `dd` for linux) and flash the provided image onto an SD card and insert into your board to start having fun.  

## Install Docker  

See the latest installation method for your distro from Docker's website.  
The following was used to install on the **_host_** build system:  

* Install the package dependencies

    ```shell
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    ```

* Add Docker Keys  

    ```shell
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    ```

* Add Docker's repository to the package manager

    ```shell
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    ```

* Install Docker

    ```shell
    sudo apt-get install docker.io
    ```

* Follow the [post-install steps for Docker](https://docs.docker.com/engine/install/linux-postinstall/). </br>
Most importantly, create a new group called docker and add your username to it. **Changes take affect upon logging in again (reboot)**: </br>
`sudo usermod -aG docker $USER && newgrp docker && su -l $USER`  

**_Optional_:** If you'd like to change the docker storage location to an external device, feel free to do the following:  

* Edit /etc/docker/daemon.json (if it doesn’t exist, create it) and include:

    ```json
    {
    "data-root": "/new/path/to/docker-data"
    }
    ```

* Then restart Docker with:

    ```shell
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    ```
