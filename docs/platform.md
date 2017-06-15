Important Note: Following instructions are written only for Ubuntu 16.04 or later hypervisor host

# platctl

The CodeLingo platform runs on a single node Kubernetes cluster deployed onto a single VM. The platctl tool is used to manage the full lifecycle of this cluster, from initial deployment to monitoring and teardown.

VM refers to the virtual machine inside which the platform containers run. The host machine is the server on which the VM's hypervisor is running.

## Prerequisite

A hypervisor and the [codelingo-onprem.ova](https://drive.google.com/drive/u/1/folders/0B1mECGkVsAMLN1Bmem8yb1AzdVk) are required. Platctl automates deployment on [Virtualbox](https://www.virtualbox.org/wiki/Downloads), but can support deployment onto any hypervisor.

## Install
[Download](https://drive.google.com/drive/u/1/folders/0B1mECGkVsAMLN1Bmem8yb1AzdVk) a pre-built binary or, if you have [Golang setup](https://golang.org/doc/install), install from source:

```bash
$ git clone https://github.com/codelingo/platctl $GOPATH/src/github.com/codelingo/platctl
$ cd $GOPATH/src/github.com/codelingo/platctl
$ go install
```

# Usage

Before we can deploy the platform, we need to setup the VM to which it will be deployed.

### Virtualbox

Import the ova:

```bash
$ platctl vbox import-appliance
```

You'll be promted for the filepath to the codelingo-onprem.ova that we downloaded in the above step.
Then you will be prompted for system resource allocation for CPU and Memory.
The command will print `Successfully imported the appliance.` when the import is completed successfully. If an error was reported, repeat the import manually using the virtualbox interface.

### Other Hypervisor

Import codelingo-onprem.ova with at least the minimum system resources:

```
CPUs: 1
Memory: 8192MB
```

## Deploy platform

For platctl to orchestrate deployment, it needs a home directory to write out several configuration files. By default it expects this home to be at /etc/codelingo/platctl. To set a different home directory set the environment variable $PLATCTL_HOME to the home directory.

In either case platctl expects the directory to exist and to allow read/write access.

Show all available network interfaces and select one of them to be the bridged adapter for the VM (e.g. enp0s3):

```bash
$ ifconfig
```

Set static IP to ensure the availability of the platform across router reboot or restart:

```bash
$ platctl ip set-static 
```

You wil be prompted to enter the network interface name, then select a static IP within the chosen network. The VM will be started with the selected IP when the process is completed.

The IP of the VM created by `platctl ip set-static` will be used as the platform IP in platform setup. 

Run the following command to start up the platform and enter the IP set in the previous step when prompted.

```bash
$ platctl platform up
```

Note: During platform setup, a platctl configuration file and a ssh private key to access the VM are created in the platctl home directory. 

Congratulations! You've just deployed the CodeLingo platform. To confirm it's running correctly, run the following commands:

```bash
$ platctl util get-pods
```

You should get an output similar to this:

```
NAMESPACE          NAME                                                              READY     STATUS             RESTARTS   AGE
default            gogs-3528918852-35sg8                                             1/1       Running            0          59m
default            php-lex-2700819787-6wqk8                                          3/3       Running            0          58m
default            platform-3732528469-7wmlx                                         1/1       Running            0          58m
default            postgres-3789429173-vzx51                                         1/1       Running            0          59m
default            website-3391169752-nvhhd                                          1/1       Running            0          58m
...
```

You can now [setup Lingo client](/getting-started).

### System Administration

Update the platform. Run the command below and enter the path to the new platform docker image file when prompted:

```bash
$ platctl platform update
```

Tear down the platform. This will remove all resources associated with the platform.

```bash
$ platctl down
```

Run a system check:

```bash
$ paltctl system-check
```

Reset to use a dynamic IP:

```bash
$ platctl ip set-dynamic
```

Current platform IP:

```bash
$ platctl ip get
```

Re-add private key:

```bash
$ platctl util add-key
```

Start the VM that runs the platform and enter the name of the selected interface when prompted:

```bash
$ platctl vbox up
```

To shut down the VM:

```bash
$ platctl vbox down
```
