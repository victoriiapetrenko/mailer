Cordova Mailer Plugin
============================

Wrapper for Apple's MFMailComposeViewController from iOS with attachments for sending pdf documents with choosed pages.

### Plugin's Purpose
The purpose of the plugin is to send pdf documents with choosed pages by MFMailComposeViewController (iOS).

## Overview
1. [Supported Platforms](#supported-platforms)
2. [Installation](#installation)
3. [Using the plugin](#using-the-plugin)
4. [Known issues](#known-issues)

## Supported Platforms ##

* Cordova >=4.4.0
  * iOS 11+

## Installation ##

The plugin can either be installed from git repository, from local file system
through the [Command-line Interface][CLI],
or cloud based through [PhoneGap Build][PGB].

The plugin is published at the [npm plugin registry][CDV_plugin].

An [ionic native wrapper][ionic] for the plugin is available.

### Local development environment
From master:
```bash
# ~~ from master branch ~~
cordova plugin add https://github.com/victoriiapetrenko/mailer.git
```
from a local folder:
```bash
# ~~ local folder ~~
cordova plugin add cordova.plugins.mailerplugin --searchpath path/to/plugin
```
or to use the last stable version:
```bash
# ~~ stable version ~~
cordova plugin add cordova.plugins.mailerplugin
```
or to use a specific version:
```bash
# ~~ stable version ~~
cordova plugin add cordova.plugins.mailerplugin@[VERSION]
```

For available versions and additional information visit the [npm plugin registry][CDV_plugin].


## Using the plugin ##

The plugin creates the object ```cordova.plugins.mailerplugin```.

The Mailer Plugin has two methods: 

1) getDocumentPagesCount: function (url, onSuccess, onError)


Example:

var pagesCount = MailerPlugin.getDocumentPagesCount(nativeURL, function () {
    return resolve();
}, function (errMsg) {
    return reject(new Error(errMsg));
});

2) sendMail: function (url, pages, onShow, onClose, onError)

Example:

MailerPlugin.sendMail(nativeURL, pages, function () {
    return resolve();
}, function () {
    return resolve();
}, function (errMsg) {
    return reject(new Error(errMsg));
});

### Common Arguments ###

#### url ####
String pointing to a device local file (e.g. 'file:///...')

#### pages ####
Array of selected pages (e.g. [1, 2, 3])

### Get a Document Pages Count ###
```js
cordova.plugins.MailerPlugin.getDocumentPagesCount(
    url, onSuccess, onError);
```

### Send a Document File ###
```js
cordova.plugins.MailerPlugin.sendMail(
    url, pages, onShow, onClose, onError);
```

#### onShow ####
```js
function onShow(){
  window.console.log('document shown');
  //e.g. track document usage
}
```
#### onClose ####
```js
function onClose(){
  window.console.log('document closed');
  //e.g. remove temp files
}
```

#### onError ####
```js
function onError(error){
  window.console.log(error);
  alert("Sorry! Cannot send document.");
}
```

## iOS ##

The plugin uses the PDFKit framework.

Mailer plugin includes the MailerPlugin h, m files.
Native Mthods:

- (void)getDocumentPagesCount:(CDVInvokedUrlCommand*)command;
- (void)sendMail:(CDVInvokedUrlCommand*)command;

## Android ##

Not available


[cordova]: https://cordova.apache.org
[CLI]: http://cordova.apache.org/docs/en/edge/guide_cli_index.md.html#The%20Command-line%20Interface
[winjs]: http://try.buildwinjs.com/
[ionic]: https://github.com/victoriiapetrenko/mailer


