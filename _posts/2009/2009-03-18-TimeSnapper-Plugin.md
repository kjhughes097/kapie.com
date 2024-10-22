---
title: "TimeSnapper Plugin"
date: "2009-03-18T12:32:14"
tags: [
  "development"
]
---
Yesterday on Leon’s Blog, [secretGeek](http://www.secretgeek.net/), I noticed they had [released v3.4](http://timesnapper.com/releasenotes.aspx) of TimeSnapper. One of the features that caught my eye was the ability to develop/add [plugins](http://timesnapper.com/pluginhowto.aspx) to it.

![timesnapper_screen](/assets/images/timesnapper-plugin-timesnapper_screen_thumb.png)

I love plugins, I’ve written plugins for [Windows Live Writer](WindowsLive-Writer-Plugin), [Outlook](SMS-Gateway-follow-up), [dasBlog](Dasblog-Macros-Code), and [more](Insert-Geo-Microformat-Plugin-for-Windows-Live-Writer).  Everything should have an SDK or plugin’able architecture. I championed it at work and we were one of the first Archiving Vendors with a ‘real’ SDK (I’ve built demo Vista Gadgets, integration scripts, federated search providers and PowerShell commandlets for it).

Anyway, the TimeSnapper plugin model looked really clean and easy to use. Read the one page description and your ready to go (didn’t even download the sample code – it was so clear how things worked there was no need).

![twitpic_logo](/assets/images/timesnapper-plugin-twitpic_logo_thumb.gif)

I wanted a little play around with it, so I though upload a snapshot to [TwitPic](http://www.twitpic.com/) would be a good idea. Opening a new project in Visual Studio, adding a reference to the ITimeSnapperPlugin.dll, create a new inherited class from ITimeSnapperPlugin and implement the interface :

```
#region ITimeSnapperPlugin Members

bool ITimeSnapperPlugin.Configurable
{
    get { return true; }
}

void ITimeSnapperPlugin.Configure()
{
    System.Windows.Forms.Form frm = new TwitPicPluginConfig();
    frm.ShowDialog();
}

string ITimeSnapperPlugin.Description
{
    get { return "Uploads snapshots to TwitPic"; }
}

string ITimeSnapperPlugin.FriendlyName
{
    get { return "TwitPic Plugin"; }
}

object ITimeSnapperPlugin.HandleEvent(TimeSnapperEvent TimeSnapperEvent, EventArgs args)
{
    switch (TimeSnapperEvent)
    {
        case TimeSnapperEvent.SnapshotSaved :
            // upload it it to TwitPic
            if (IsTimeToUpload())
            {
                string fileName = ((TimeSnapperPluginAPI.SnapshotSavedEventArgs)(args)).Activity.Filename;
                Debug.WriteLine("Uploading " + fileName + " to TwitPic");
                XmlDocument xmlDoc = UploadToTwitPic(fileName);
            }
            break;

        default :
            Debug.Assert(false, "Should never occur");
            break;
    }
    return null;
}

TimeSnapperMenuItem[] ITimeSnapperPlugin.MenuItems()
{
    return null;
}

Guid ITimeSnapperPlugin.PluginID
{
    get { return new Guid("50744334-C5A0-44f1-BE64-5BBF32FDA79D"); }
}

TimeSnapperEvent[] ITimeSnapperPlugin.SubscribesTo()
{
    return new TimeSnapperEvent[] { TimeSnapperEvent.SnapshotSaved };
}
```

All that was required was to give it a new Guid and name/description and then subscribe to the ‘SnapShotSaved’ event and handle the event when it was triggered.

![yedda_logo](/assets/images/timesnapper-plugin-yedda_logo_thumb.jpg)  

To get the image uploaded to [TwitPic](http://www.twitpic.com/) I used some code from the excellent [Yedda Twitter C# Library](http://devblog.yedda.com/index.php/twitter-c-library/) (just the stuff for posting image data to a url).  
That all worked a breeze, but it was sending images (and posting to my twitter account) every 10 seconds (and of course it was hard coded to my username/password) – what was needed was a bit of configuration…

Luckily the plugin model provides an excellent and easy way to do this (set the Configurable property to true, and handle the Configure event). A bit more jiggery pokery, one modal dialog and an XML config file later, it was all working (configurable username, password, twitter message and frequency of updates) – although I really should do something better than store the username/password in clear text in an XML file…

If you want the plugin, just drop [this dll](/assets/files/timesnapperplugin/twitpicplugin.dll) into your `%install%\plugins` folder and restart TimeSnapper.
