---
title: "Cannot create Edge Subscription file"
date: "2010-02-23T11:59:23"
tags: [
  "technical"
]
---
This is a pretty obscure gotcha..

I was trying to export an Edge Subscription XML file from my Edge Transport server (a demo Exchange 2010 environment)  
There is no GUI for this in Exchange Management Console, so you have to use the Exchange Management Shell.

Opened up EMS and entered the command :

`New-EdgeSubscription –Filename “c:Edge.xml”`

![image](/assets/images/cannot-create-edge-subscription-file-image_thumb.png)

![image](/assets/images/cannot-create-edge-subscription-file-image_thumb_1.png)  

I kept getting an error saying that “***When running this task inside the organization, the Filename parameter must NOT be set***.” Also, Google told me that a bunch of other people had experienced similar issues but had not found a solution.  
A little investigation into why it thought I was ‘inside the organization’ uncovered that I had set the primary DNS suffix the same as the domain name. Changing this to something else, rebooting the server and trying it all again worked a treat.

Now… back to that Edge Subscription…
