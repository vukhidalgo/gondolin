# tishy

Personal atomic Linux desktop attempt, based on Bazzite.

Thanks to [Isengard](https://github.com/noelmiller/isengard) which I've forked here.

# G9 57 modifications

[`system_files/usr/lib/firmware/edid/g957_modified.bin`](system_files/usr/lib/firmware/edid/g957_modified.bin) contains a modified EDID for the 2023
[Samsung G9 Odyssey 57" (G95NC)](https://www.samsung.com/us/computing/monitors/gaming/57-odyssey-neo-g9-dual-4k-uhd-quantum-mini-led-240hz-1ms-hdr-1000-curved-gaming-monitor-ls57cg952nnxza/) monitor. The EDID is based on the output the monitor produces with these settings:

* Firmware version 1005.3
* DisplayPort 2.1
* FreeSync Premium Pro on
* Refresh rate set to 240 Hz

To this base, the following changes were made via the excellent [AW EDID Editor](https://www.analogway.com/americas/products/software-tools/aw-edid-editor/), run through Wine:

* Add a 7680x2160 120Hz refresh rate (settings copied over from the EDID produced with a 120Hz refresh rate monitor).
* Remove YCrCb 4:4:4 and 4:2:2 from both the "Feature Support" section and the "CEA Extension/Header" section. This is to work around the lack of configurability in amdgpu [(issue)](https://gitlab.freedesktop.org/drm/amd/-/issues/476).
* Reset serial to a generic value (0x12345678).

This file is added to initramfs via [this dracut config](system_files/usr/lib/dracut/dracut.conf.d/zz-tishy-edid.conf) and a `/usr/libexec/containerbuild/build-initramfs` invocation in the [Containerfile](Containerfile).

As of 2024-11-16, this appears to work well -- I can confirm that I see the 7680x2160 120Hz option. (Note, however, that currently FreeSync/VRR on DisplayPort 2.1 is broken in amdgpu.)

In the future I plan to add 5160x2160 240Hz, 120Hz and 60Hz refresh rates, probably replacing some of the other ones I don't currently use.
