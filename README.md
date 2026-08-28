# arcade-machine

The arcade machine runs [Batocera](https://batocera.org/), a Linux distribution built around their fork of [EmulationStation](https://github.com/batocera-linux/batocera-emulationstation).

## Hardware issues

The two backpanel USB 2 ports are faulty. The primary symptom of this is that when the computer is booted, there is a high chance that the ports will be non-functional. This state may then persist for anywhere from zero to several subsequent reboots.

## Controls

EmulationStation keyboard bindings use these keycodes: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/keyCode

Controller buttons displayed in UI legend are purely directional. But in config and elsewhere in the UI they label them according to the Xbox layout:

| Direction/UI | Config |
|--------------|--------|
| Up           | `y`    |
| Down         | `a`    |
| Left         | `x`    |
| Right        | `b`    |

<img src="https://upload.wikimedia.org/wikipedia/commons/6/67/Microsoft-Xbox-One-controller.jpg?utm_source=en.wikipedia.org&utm_campaign=index&utm_content=original" width="200" />

Current keyboard bindings:
| Key        | Action          |
|------------|-----------------|
| Enter      | `select`        |
| Spacebar   | `start`         |
| WASD       | `y` `x` `a` `b` |
| Arrow Keys | Joystick        |
