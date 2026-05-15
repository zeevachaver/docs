The following instructions describe the installation procedure for DataLab-developed VR software, using PullPackage, a simple custom package management tool.

### Prerequisites

DataLab's VR software runs on the Linux operating system, and requires that operating system to run on a real computer, in other words, not on a virtual machine. While DataLab's VR software runs on any Linux distribution, PullPackage (DataLab's package manager) currently only works with two large families of Linux distributions:

* RedHat (RedHat Linux, CentOS, Fedora, ...)
* Ubuntu (Ubuntu, Linux Mint, ...)

Additionally, running DataLab's VR software effectively requires that the computer has a discrete graphics card, and has the drivers for that graphics card installed.

In detail, the prerequisite installation steps are as follows:

1. Install a compatible (RedHat- or Ubuntu-based) Linux version on a real computer (not a virtual machine), either as sole operating system or in a dual-boot configuration.

2. Install the proper driver for the computer's discrete graphics card. For Nvidia graphics cards, this must be the vendor-supplied nvidia driver, not the open-source nouveau driver.

#### Install PullPackage

To install the PullPackage package manager, copy the command from the following box into a terminal window and press ++enter++:

```sh
curl https://vroom.library.ucdavis.edu/PullPackage | bash
```

At some point during installation, the terminal window will ask you to enter your user password. This is required to create files in several system locations. Specifically, those locations are:

```sh
/opt/PullPackage
/usr/local/bin
```

Later on, PullPackage may ask for your user password again to install packages such as Vrui or SARndbox. Generally, software packages installed by PullPackage end up inside the `/opt` directory, and may create files in `/usr/local/bin` and inside the `/etc` directory.

If the terminal responds with an error message like `bash: curl: command not found`, please copy and run the following alternative command:

```sh
wget -O - https://vroom.library.ucdavis.edu/PullPackage | bash
```

If either of the two commands above succeed, you are ready to install DataLab VR software using PullPackage.