# The CodeLingo Platform 
#### On Premise Install

<br/>
### Overview

The CodeLingo OnPrem Platform runs on a single node Kubernetes cluster deployed onto a single VM. All resources for the CodeLingo OnPrem Platform are packaged within a single Open Virtual Appliance (OVA) which can be imported into any major hypervisor. The following instructions are written for an Ubuntu 16.04 (or later) host.


The CodeLingo OnPrem Platform comes with a SysAdmin tool: *platctl*. The platctl tool streamlines the management of the cluster: from initial deployment to updates, monitoring and teardown.

<br/>
### Prerequisite

A hypervisor and the [codelingo-onprem.ova](https://drive.google.com/drive/u/1/folders/0B1mECGkVsAMLN1Bmem8yb1AzdVk) are required. Platctl automates deployment on [Virtualbox](https://www.virtualbox.org/wiki/Downloads), but can support deployment onto any hypervisor.

<br/>
### Install Platctl

[Download](https://drive.google.com/drive/u/1/folders/0B1mECGkVsAMLN1Bmem8yb1AzdVk) the pre-built binary of platctl onto the hypervisor host and place it on host's $PATH.

<br/>
### Install OVA

To install the OVA run:

```bash
$ platctl vbox import-appliance
```

When prompted, supply the filepath to the codelingo-onprem.ova file, CPU and Memory system resource allocation. On a successful import, the command will print `Successfully imported the appliance.`.  If an error was reported, or a hypervisor other that virtualbox is used, repeat the import manually using the hypervisor's interface with the following minimum system resources:

```
CPUs: 1
Memory: 8192MB
```

<br/>
### Deploy The CodeLingo OnPrem Platform

Run the following command to set the IP of the CodeLingo OnPrem Platform VM:

```bash
$ platctl ip set-static
```

The command will prompt for an IP and a network interface name to use as the CodeLingo OnPrem Platform address. Run `$ ifconfig` to list all available network interfaces and select one of them to be the bridged adapter for the VM (e.g. enp0s3) and select a static IP within the chosen network.

Run the following command to start up the CodeLingo OnPrem Platform:

```bash
$ platctl platform up
```

Congratulations! You've just deployed the CodeLingo OnPrem Platform.

---

*Under The Hood*: During platform setup, a platctl configuration file and a ssh private key to access the VM are created in the platctl home directory. The home directory is at /etc/codelingo/platctl by default. Set the environment variable $PLATCTL_HOME to override this default. In either case platctl expects the directory to exist and to allow read/write access.

### Confirm Deployment

To confirm the CodeLingo OnPrem Platform is running correctly, run the following command:

```bash
$ paltctl system-check
```

You can now [setup the lingo client](/getting-started).


### System Administration

The platctl tool has many commands to help SysAdmins manage the CodeLingo OnPrem Platform. The following list highlights some of the more common commands.


List all pods in the CodeLingo OnPrem Platform cluster:

```bash
$ platctl util get-pods

NAMESPACE          NAME                        READY     STATUS             RESTARTS   AGE
default            gogs-3528918852-35sg8       1/1       Running            0          59m
default            php-lex-2700819787-6wqk8    3/3       Running            0          58m
default            platform-3732528469-7wmlx   1/1       Running            0          58m
default            postgres-3789429173-vzx51   1/1       Running            0          59m
default            website-3391169752-nvhhd    1/1       Running            0          58m
...
```

Update the CodeLingo OnPrem Platform. The command will prompt for the filepath to the new CodeLingo OnPrem Platform Docker image:

```bash
$ platctl platform update
```

Tear down the CodeLingo OnPrem Platform and remove all resources associated with it.

```bash
$ platctl down
```

Run a system health check:

```bash
$ paltctl system-check
```

Current platform IP:

```bash
$ platctl ip get
```

Re-add private key:

```bash
$ platctl util add-key
```

Start the CodeLingo OnPrem VM:

```bash
$ platctl vbox up
```

Shut down the CodeLingo OnPrem Platform VM:

```bash
$ platctl vbox down
```
