### Installing ARSandbox

The SARndbox package contains the actual ARSandbox application. The [Vrui](https://vrui-vr.github.io/vrui/installation/) and [Kinect](https://vrui-vr.github.io/kinect/installation/) packages are mandatory prerequisites for ARSandbox.

```sh
PullPackage SARndbox
```

Alternatively, the following command will install all three packages required for the ARSandbox in one go:

```sh
PullPackage Vrui && PullPackage Kinect && PullPackage SARndbox
```