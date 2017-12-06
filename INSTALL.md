## Installation Instructions

These steps should work on a Fedora 27 system.  If you are using CentOS 7
or RHEL 7, specify 'yum' instead of 'dnf' and make sure you have the EPEL
repository enabled.  Any other yum-specific steps are noted in the steps
below.

### SETUP

1. Ensure you have basic development tools installed in order to build
   the SRPMs and perform package management tasks:

        dnf install fedora-packager rpmdevtools mock createrepo

2. Download the SRPMs for the demo:

        make fetch

   This runs the ./mk/fetch.sh script and downloads the files listed in
   the ./conf/srpmlist file.  The checksums are validated against the
   ones in ./conf/checksums.

3. Build all of the packages and create the local repos:

        make build

   This runs the ./mk/build.sh script and builds all of the SRPM files
   and combines the built packages in to a local repo.  Builds may fail,
   so you might want to capture the build output with '2>&1 | tee log'
   or something similar to resolve problems.

   For the purposes of this demo, the packages are built with an override
   for the %{_prefix} macro.  It's set to '/opt/$ID/%{name}/%{version}'
   where ID comes from /etc/os-release.  For Fedora systems, this is
   'fedora', for RHEL it's 'rhel', and for CentOS it's 'centos'.  The
   name and version values come from the package itself.  This sets up
   each package to be self-contained in its own tree in /opt.

## INSTALL PACKAGES

1. You need to make some changes to the dnf configuration.  You can do
   this with command line options or edit the configuration files on
   the system.  For this example, we will use command line options:

       # Include our demo repo in this example.  The alternative would
       # be to add a new repo file in /etc/yum.repos.d/
       DNFOPTS="$DNFOPTS --repofrompath multipass,$(pwd)/repo/$(uname -m)"

       # Override the installonly limit to allow any number of packages
       # and their versions to be installed.  The alternative is to set
       # this value in /etc/dnf/dnf.conf.
       #
       # NOTE: This needs to go after other options on the dnf command line.
       DNFOPTS="--setopt=installonly_limit=0"

2. XXX




