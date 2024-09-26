import Foundation
import AVFoundation
import SwiftUI
import UserNotifications
import MediaPlayer

class ColdwaveState: ObservableObject {

    @AppStorage("music.folder") var path = ""
    @Published var albums: [Album] = []
    //@Published var path = "";
    @Published var currentAlbum: Album?
    @Published var currentTrack = 0
    @Published var currentTitle: String = ""
    @Published var coverSize: CGFloat = DEFAULT_IMAGE_SIZE
    @Published var playlist: [URL]  = []
    @Published var amountPlayed: Double = 0.0 // in range 0...1
    @Published var playing: Bool = false
    @Published var searchText: String = ""
    @Published var timePlayed = 0
    @Published var timeRemaining = 0

    let player: AVPlayer = AVPlayer()
    let npCenter: MPNowPlayingInfoCenter = MPNowPlayingInfoCenter.default()

    init() {
        player.allowsExternalPlayback = true

        player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main
        ) { t in
            // Compare two CMTimeScales and update slider via state,
            // converting the track duration units to match the amountPlayed units.
            if let duration = self.player.currentItem?.duration.convertScale(t.timescale, method: CMTimeRoundingMethod.default) {
                self.amountPlayed = Double(t.value) / Double(duration.value)
                self.timePlayed = Int(t.seconds)
                let d = duration.seconds
                self.timeRemaining = d.isNaN ? 0 : Int(d - t.seconds)

                self.updateNpInfo()
            }
        }

        npCenter.playbackState = .stopped
        // setupRemoteControls()
        requestNotifications()

        if path != "" {
            albums = Album.scanLibrary(at: path)
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
            currentTitle = playlist[trackNumber].lastPathComponent
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

            npCenter.playbackState = .playing
            updateNpInfo()
        } else {
            player.pause()
            playing = false
            npCenter.playbackState = .stopped
            updateNpInfo()
        }
    }

    func pause () {
        player.pause()
        playing = false
        npCenter.playbackState = .stopped
    }

    func play () {
        if (player.currentItem != nil) {
            player.play()
            playing = true
            npCenter.playbackState = .playing
        }
    }

    func requestNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, /* .sound, .badge,*/ .provisional]) { granted, error in
            if error != nil {
                NSLog("UN requestAuthoriziation %@", error!.localizedDescription)
            } else {
                NSLog("UN requestAuthorization %@", granted ? "granted" : "denied")
            }
        }
    }

    func notify(title : String, message : String) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) ||
                  (settings.authorizationStatus == .provisional) else {
                NSLog("Notifications not authorizided nor provisional")
                return
            }

            if settings.alertSetting == .enabled {
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = message
                content.categoryIdentifier = "abyrd.Coldwave"

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
            } else {
                NSLog("Alert notifications are disabled")
            }
        }
    }

    /*
    private func setupRemoteControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            NSLog("remote pause")
            notify(title: config!.title, message: "Pause")
            playerPause()
            return .success
        }
        commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            NSLog("remote play")
            if current < 0 {
                playNext()
            } else {
                playerPlay()
            }
            return .success
        }
        commandCenter.togglePlayPauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            NSLog("remote playPause")
            if player.timeControlStatus == .playing {
                notify(title: config!.title, message: "Pause " + currentTitle())
                playerPause()
            } else {
                if current < 0 {
                    playNext()
                } else {
                    playerPlay()
                }

                notify(title: config!.title, message: "Play " + currentTitle())
            }
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            NSLog("remote next")
            let index = selectNext(forward: true)
            playerSelect(index: index, play: true)
            notify(title: config!.title, message: "Play " + currentTitle())
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            NSLog("remote next")
            let index = selectNext(forward: false)
            playerSelect(index: index, play: true)
            notify(title: config!.title, message: "Play " + currentTitle())
            return .success
        }
    }
     */

    private func updateNpInfo() {
        npCenter.nowPlayingInfo = [
            MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue,
            MPNowPlayingInfoPropertyIsLiveStream: false,
            //MPNowPlayingInfoPropertyPlaybackRate: player.rate,
            MPMediaItemPropertyTitle: currentTitle,
            MPMediaItemPropertyPodcastTitle: currentTitle,
            MPNowPlayingInfoPropertyAssetURL: playlist[currentTrack],
            MPMediaItemPropertyArtist: currentAlbum?.artist ?? "",
            //MPMediaItemPropertyPlaybackDuration: player.currentItem?.duration as Any,
            //MPNowPlayingInfoPropertyElapsedPlaybackTime: player.currentTime(),
            //MPMediaItemPropertyArtwork: currentAlbum?.coverImagePath as Any,
        ]
    }
}
