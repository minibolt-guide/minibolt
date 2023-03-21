---
layout: default
title: Store data in a secondary disk
parent: + System
grand_parent: Bonus Section
nav_exclude: true
has_toc: false
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->

# Bonus Guide: Store data in a secondary disk

{: .no_toc }

---

If you want to use a different disk to store data (blockchain and other databases) independently of the disk of the system, you can follow these instructions.

Difficulty: Easy
{: .label .label-green }

Status: Tested MiniBolt
{: .label .label-blue }

---

## Table of contents
{: .text-delta }

1. TOC
{:toc}

---

When you arrive at the **"Guided storage configuration"** (step 8) on the [Ubuntu server installation](../../system/operating-system.md#ubuntu-server-installation), follow the next steps:

* Select this time **"Custom storage layout"** and press **"Done"**

Under **AVAILABLE DEVICES** you will see both drives you installed on the PC, identify each one by drive model name and storage
It is recommended to choose the smallest size drive for the system and the bigger size driver for the data storage **`(/data)`**.

* Select the section where appeared the **MODEL** of the primary disk between `"[]"` and press enter -> Select **"Use As Boot Device"** and press enter again

This will select this storage as the boot disk and create automatically a new partition for the **"BIOS grub spacer"** on it.

* Select the **"free space"** section of the same device, and select **"Add GPT Partition"**. Ensure the format is selected as `"ext4"`, select **"/"** in the dropdown as mount point, select **"Create"** and press enter

* Now select the **"free space"** of the **secondary disk** on "AVAILABLE DEVICES" -> **Add GPT partition**. Ensure the format is selected as `"ext4"`, select **"Other"** in the dropdown, type `/data` to assign to the new **("/data")** folder, select **"Create"** and press enter

* Select **"Done"** and press enter. Confirm destructive action warning banner hitting **"Continue"**

🚨 **This will delete all existing data on the disks, including existing partitions!**

![Storage secondary disk GIF](../../../resources/storage-secondary-disk.gif)

### Continue with the guide

That's it: your PC now boots from the primary disk while the data directory **`(/data)`** is located on the secondary disk.

**-->** Now you can continue with step **11** of the [Ubuntu Server installation](../../system/operating-system.md#ubuntu-server-installation)

---

Next: [Ubuntu Server installation, step 11 >>](../../system/operating-system.md#ubuntu-server-installation)

<< Back: [+ System](index.md)