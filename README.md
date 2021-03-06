# coldwave

Coldwave is an album-oriented FLAC player for macOS. This is a minimum viable prototype created in January 2015 as a way to familiarize myself with the then-new Swift language and enable listening to a collection of CDs I'd ripped to FLAC in anticipation of a long-distance move. It is an experiment with a simple way of organizing and presenting albums for listening. I am hoping to bring this up to date with current (2021) versions of Swift and XCode and make it suitable for daily use.

## Characteristics

Coldwave does not require files to be tagged, or even look at tags. It is convention-driven, getting artist, album, and track titles from directory structure and filenames. It aims to play whole albums while showing large album art, and allow choosing an album by scrolling through pages of album art.

It also avoids the certain complex arrangements where an audio player daemon indexes files on a network drive and is remote-controlled by a client. Coldwave scans the files itself and plays the audio, then AirPlay or Bluetooth capabilities built into the OS can be used as needed to send audio to amplifiers and speakers (in my case via the intermediary shairport-sync and HiFiBerryOS).

Audio playback is provided by the OrigamiEngine and FLAC libraries. Coldwave is essentially a directory-browsing wrapper around those libraries.
