# FatCat (KDE Plasma 6 Plasmoid)

An animated desktop cat that grows wider according to system RAM or GPU VRAM usage.

Requires KDE Plasma 6, KSystemStats, and LibKSysGuard's `org.kde.ksysguard.sensors` QML module.

## Install

```bash
kpackagetool6 --type Plasma/Applet --install .
# Upgrade an existing installation:
kpackagetool6 --type Plasma/Applet --upgrade .
```

Add FatCat to the desktop or a panel. Open the widget's configuration and select **System RAM usage** or **GPU VRAM usage**.

## How it works

- Native KSystemStats sensors track RAM use (`memory/physical/usedPercent`) or aggregate VRAM use (`gpu/all/usedPercent`).
- Used/total sensor pairs serve as fallbacks, followed by the first GPU when aggregate VRAM sensors are unavailable.
- GPU reporting depends on the sensors exposed by your graphics driver and KSystemStats.
- Sensor IDs remain fixed for the widget's lifetime. Sensor updates are rate-limited to 1000 ms.
- No `nvidia-smi` subprocesses, Plasma 5 data engines, or local-file XMLHttpRequests are used.

## Test

```bash
plasmoidviewer -a org.kde.plasma.fatcat
```

Switch between RAM and VRAM in the widget settings and compare its size against KDE System Monitor. To inspect exposed sensors, open System Monitor and browse its sensor list. Plasma 5 is not supported.
