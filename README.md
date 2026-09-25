# arcade-machine

The arcade machine runs a custom [bootc](https://github.com/bootc-dev/bootc) image based on Fedora. This image is built based on the [image template](https://github.com/ublue-os/image-template) provided by the Universal Blue Project.

## Hardware issues

The two backpanel USB 2 ports are faulty. The primary symptom of this is that when the computer is booted, there is a high chance that the ports will be non-functional. This state may then persist for anywhere from zero to several subsequent reboots.

## Controls

The four buttons adjacent to the joysticks are mapped to the Xbox YXAB buttons as follows:

| Direction | Xbox |
|-----------|------|
| Up        | `y`  |
| Down      | `a`  |
| Left      | `x`  |
| Right     | `b`  |

<img src="https://upload.wikimedia.org/wikipedia/commons/6/67/Microsoft-Xbox-One-controller.jpg?utm_source=en.wikipedia.org&utm_campaign=index&utm_content=original" width="200" />
