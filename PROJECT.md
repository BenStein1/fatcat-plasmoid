---
name: org.kde.plasma.fatcat
status: null
summary: KDE Plasma widget visualizing RAM and GPU memory as a cat.
next: Test Plasma 6 native sensors and compare KDE SVG vs Qt Quick Image rendering.
updated: 2026-10-27
olivetin: false
---

# org.kde.plasma.fatcat

[[Projects.base|All projects]]
- [📄 Git status](http://127.0.0.1:1337/custom-webui/run.html?project=org.kde.plasma.fatcat&action=Git+status)

## Current state

KDE Plasma widget visualizing RAM and GPU memory as a cat.

Source: [[org.kde.plasma.fatcat/README.md|README.md]]. Plasma 6 sensor support is implemented. Two renderers (KSvg and Qt Quick Image) are available for comparison.

## How to run

Install or upgrade with `kpackagetool6 --type Plasma/Applet --upgrade .`; add FatCat to the desktop and choose its metric and renderer in widget settings.

## Next

- [ ] Test RAM and GPU VRAM sensor readings on Plasma 6.
- [ ] Compare KDE SVG and Qt Quick Image rendering.
- [ ] Profile memory stability over prolonged use.

## Notes

OliveTin actions are disabled until a suitable run command is confirmed.
