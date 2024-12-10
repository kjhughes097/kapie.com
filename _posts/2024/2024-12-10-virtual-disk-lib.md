---
title: Virtual Disk Lib
date: 2024-12-10T18:21:41
tags: [
  blog
]
image: /assets/images/virtual-disk-lib.png
---
A few months ago I was working on some VHD and VHDX file format conversions (because Azure Disks can only be created from 'Fixed VHD' format disks).
There were/are a few challenges to this, so I thought I'd write a library for it, and show how to work through the problems.

I'll document the process and thinking here.
It'll be written in C# (at least initially, I may add Python, Golang, Rust too as I'd like to get a bit more familiar with those languages)

I'll take an iterative approach. Major steps will be:

- Document requirements / expectations
- Set up environment, CI/CD
- Parsing file/header information
- Reading data
  - Fixed VHD
  - Dynamic VHD
  - Differencing VHD
  - Dynamic VHDX
  - Differencing VHDX

Links to the updates / articles will appear below.
