### Install Support for SteamVR Headsets (HTC Vive, HTC Vive Pro, Valve Index...)

In order to use SteamVR-compatible commodity VR headsets with Vrui VR software, install the SteamVR package before installing the Vrui package:

```sh
PullPackage SteamVR
```

??? note
    The SteamVR package is not a complete Steam and/or SteamVR installation. It only contains the low-level drivers required to connect Vrui VR software to SteamVR headsets. To avoid compatibility issues, we strongly recommend that you install this package even if you already have Steam and/or SteamVR installed on your computer.

### Install Other Vrui VR Applications
To install other Vrui VR applications such as 3D Visualizer, LiDAR Viewer, VR ProtoShop, etc., first install the Vrui package (and optionally the SteamVR package before it), then install the package(s) for the desired Vrui application(s).
