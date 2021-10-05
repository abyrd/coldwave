import Foundation
import AVFoundation

class ColdwaveState: ObservableObject {
    
    @Published var albums: [Album] = []
    @Published var path: String = "";
    @Published var currentAlbum: Album?
    @Published var currentTrack = 0
    @Published var coverSize: CGFloat = DEFAULT_IMAGE_SIZE
    @Published var playlist: [URL]  = []
    @Published var amountPlayed: Double = 0.0 // in range 0...1
    @Published var playing: Bool = false
    @Published var searchText: String = ""

    let player: AVPlayer = AVPlayer()

    init() {
        player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main
        ) { t in
            // Compare two CMTimeScales and update slider via state,
            // converting the track duration units to match the amountPlayed units.
            if let duration = self.player.currentItem?.duration.convertScale(t.timescale, method: CMTimeRoundingMethod.default) {
                self.amountPlayed = Double(t.value) / Double(duration.value)
            }
        }
    }
    
    // It doesn't seem clean to put this (or the AVPlayer) on the state, but notification
    // targets have to be objc functions which have to be members of an NSObject or protocol.
    // I could probably factor the player field and these methods out into another class.
    @objc func playerDidFinishPlaying(sender: Notification) {
        print("End of track \(currentTrack), advancing.")
        jumpToTrack(currentTrack + 1)
    }

    func jumpToTrack (album: Album, trackNumber: Int) {
        currentAlbum = album;
        playlist = album.getPlaylist()
        jumpToTrack(trackNumber)
    }

    func jumpToTrack (_ trackNumber: Int) {
        if (trackNumber >= 0 && trackNumber < playlist.count) {
            let track = AVPlayerItem(asset: AVAsset(url: playlist[trackNumber]))
            player.replaceCurrentItem(with: track)
            currentTrack = trackNumber;
            // I seem to be getting double-starts on automatic transition to next track.
            // But removing the play() call causes it to stall on the transition.
            player.play()
            playing = true
            // Deregister any previously registered end-of-track notifications to avoid memory leaks.
            NotificationCenter.default.removeObserver(self)
            NotificationCenter.default.addObserver(self,
                selector: #selector(playerDidFinishPlaying(sender:)),
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: track
            )
        } else {
            player.pause()
            playing = false
        }
    }

    func pause () {
        player.pause()
        playing = false
    }
    
    func play () {
        if (player.currentItem != nil) {
            player.play()
            playing = true
        }
    }

}
