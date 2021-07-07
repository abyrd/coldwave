# Coldwave

Coldwave is an album-oriented FLAC player for MacOS which depends on the filesystem (rather than tags) to organize files by artist and album. It was created in response to the following conditions:

- MacOS avoids supporting open lossless formats like FLAC (preferring its proprietary ALAC)
- People often organize their ripped CDs and album downloads into one folder per album
- Nonetheless, music players often require you to tag, import, and index files rather than just browsing through filesystem directories
- Audio file tags and tagging utilities are fiddly. There always seem to be some inconsistencies, incorrect fields, or untagged files
- Players don't seem to prioritize the pleasant experience of flipping through album covers, picking one that catches your interest, and listening to it all the way through from beginning to end with the album cover propped up beside you

## Background

This project began in January 2015 as a way to familiarize myself with the then-new Swift language and enable listening to a collection of CDs I'd ripped to FLAC in anticipation of a long-distance move. It was also an experiment with a simpler way of organizing and presenting albums for listening. I have recently brought this up to date with current (2021) versions of Swift and XCode and am gradually making it suitable for daily use. The current version is based on a SwiftUI LazyVGrid, while the initial 2015 prototype was based on the (now deprecated) Quartz IKImageBrowserView.

The name Coldwave refers to French post-punk music circa 1980.

## Detail

Coldwave does not require files to be tagged, or even look at tags. It is convention-driven, getting artist, album, and track titles from directory structure and filenames. It aims to play whole albums while showing large album art, and allow choosing an album by scrolling through pages of album art.

This is the currently supported directory layout:
```
Music
├── Artist One
│   ├── First Album
│   │   ├── 01 Track One.flac
│   │   ├── 02 Track Two.flac
│   │   └── cover.jpg
│   └── Second Album
│       ├── 01 Track One.mp3
│       ├── 02 Track Two.mp3
│       └── othername.png
└── Various Artists
    ├── Super Compilation
    │   ├── 01 Artist One - Track One.flac
    │   ├── 02 Artist Two - Track Two.flac
    │   └── cover.jpeg
    └── Other Compilation
        ├── 01 Artist 3 - Track A.m4a
        └── 02 Artist 4 - Track B.m4a
```

The first level of subdirectories will be interpreted as artist names and the second level as album names. Any files with suffix `.flac`, `.m4a`, or `.mp3` will be treated as audio tracks, displayed and played in lexicographical order. Naming them starting with two-digit track numbers is one way to play them in a particular order. Any files with suffix `.jpg`, `.jpeg`, or `.png` will be treated as album art, with precedence given to files whose base name is `cover`. There are no rules about how the directories and files should be named - they are just used verbatim with no further parsing.

Coldwave does not use the topology where an audio player daemon indexes files and is remote-controlled by a client (the MPD and DLNA approach). It instead adopts the more typical Apple approach where the computer running Coldwave is the hub. Coldwave reads the files itself and plays the audio, then AirPlay or Bluetooth capabilities built into the OS can be used as needed to send audio to amplifiers and speakers (in my case via the intermediary shairport-sync on HiFiBerryOS). If files are on a network drive and/or the playback device is separate from the machine running Coldwave this does use significantly more network bandwidth, but that's usually harmless when sending audio on local networks. Audio is fairly low-bandwidth and local networks often have lots of spare bandwidth.

Audio playback is provided by the OrigamiEngine and FLAC libraries. Coldwave is essentially a directory-browsing wrapper around those libraries.


## Build

`pod install`
