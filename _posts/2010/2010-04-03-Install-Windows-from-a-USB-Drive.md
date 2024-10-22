---
title: "Install Windows from a USB Drive"
date: "2010-04-03T00:31:03"
tags: [
  "technical"
]
image:  /assets/images/install-windows-from-a-usb-drive-USBdrive_thumb.jpg
teaser: 'Instructions for creating a bootable USB drive from Windows (to install Windows)'
---
![USBdrive](/assets/images/install-windows-from-a-usb-drive-USBdrive_thumb.jpg)

This post is for my own benefit more than anything. I frequently have to ‘google’ for the instructions to make a bootable USB drive to install some version of Windows from. So, to save time in the future, here are the instructions :

Open a command prompt **As Administrator**. Run `diskpart`. Enter `list disk` – this will list all the attached disks, make note of the USB drive disk number - 2 in my case - so substitute 2 in the commands below for whatever number it shows on your system :- ![image](/assets/images/install-windows-from-a-usb-drive-image_thumb.png)

```
select disk 2
clean
create partition primary
select partition 1
active
format fs=fat32 quick
assign
exit
```
