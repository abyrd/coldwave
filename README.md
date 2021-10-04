# Coldwave

Coldwave is an album-oriented FLAC player for MacOS which depends on the filesystem (rather than tags) to organize files by artist and album. It has very few features but does exactly what I want: plays FLAC rips of CDs while displaying the album cover. It was built to meet a personal need, while gaining and maintaining basic familiarity with the current state of MacOS software development.

## Rationale
Coldwave was created in response to the following conditions:

- Standard MacOS apps do not support open lossless formats like FLAC (preferring proprietary ALAC).
- People often organize their ripped CDs and album downloads into one folder per album. Nonetheless, music players often expect you to tag, import, and index files rather than just browsing through filesystem directories.
- Audio file tags and tagging utilities are fiddly. There always seem to be some inconsistencies, incorrect fields, or untagged files.
- Most music players don't prioritize the experience of flipping through album covers, picking one that catches your interest, and listening to it all the way through from beginning to end with the album cover propped on the shelf.

## Background

I created Coldwave in January 2015 as a way to familiarize myself with the then-new Swift language (and MacOS development in general). I wanted to enable listening to a large collection of CDs I'd ripped to FLAC in anticipation of a long-distance move and experiment with simpler ways of organizing and presenting these albums for listening. 

The initial 2015 prototype was based on the (now deprecated) Quartz IKImageBrowserView, with audio playback handled by OrigamiEngine via CocoaPods and the UI created in InterfaceBuilder. This did work, but was a mess of Swift-to-Objective-c bridging headers, cryptic library linking configuration, and absurdly complex, constantly conflicting auto-layout constaints despite the trivial number of UI components.

In 2021 I brought this up to date with current versions of Swift and XCode. The UI is now created programmatically in  declarative/reactive SwiftUI using its LazyVGrid view. In late 2017 with the release of MacOS High Sierra, people had discovered that individual FLAC files would play in Finder's Quick View and in Quicktime. Apps like iTunes (and now Apple Music) still ignore them, but the AVFoundation classes are capable of playing them. Coldwave FLAC (and other audio file) playback is now handled by the AVPlayer included with AVFoundation.

A standalone, local audio file player has become a little less relevant or essential than it was in 2015. Even rather obscure music is now available at high bit rates on streaming services. But some albums still aren't available on such services, and this varies due to local licensing restrictions. In many situations it's great to put on albums and listen from beginning to end, without the distraction of surfing around for the next track or the ML-generated playlist randomly dropping Merzbow. I am also frequently on an island where I want to listen to CD quality audio for hours without dropouts, pauses and quality degradation even when the free-air radio link to the rest of the internet is saturated or experiencing rain fade.

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

## Build

This should build with no special configuration in recent versions of XCode. It no longer uses any external libraries so there's no special configuration or dependencies to install. Once built you can drag the app bundle out of the "products" section in XCode into your Applications folder.   
