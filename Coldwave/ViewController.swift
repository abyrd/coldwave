//
//  ViewController.swift
//  Coldwave
//
//  Created by Andrew Byrd on 1/2/15.
//  Copyright (c) 2015 Andrew Byrd. All rights reserved.
//

import Cocoa
import Quartz
import OrigamiEngine

class ViewController: NSViewController, ORGMEngineDelegate {

    @IBOutlet weak var imageBrowser: IKImageBrowserView!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var trackSelector: NSPopUpButton!
    
    var albums: [Album] = []
    var path: String = "";
    let origami = ORGMEngine()
    var timer: Timer?
    var playlist: [URL]  = []
    var currentTrack = 0
    
    // Current size and constraints on size of album images
    let MIN_IMAGE_SIZE = 100
    let MAX_IMAGE_SIZE = 600
    let IMAGE_SIZE_STEP = 50
    var imageSize = 300
    
    override func viewDidLoad() {
        super.viewDidLoad()
        origami.delegate = self
        imageBrowser.setCellSize(NSSize(width: imageSize, height: imageSize))
    }
    
    func switchPath (_ newPath: String) {
        path = newPath;
        albums = Album.scanLibrary(path)
        imageBrowser.reloadData()
        // imageBrowser.needsDisplay = true;
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    // Expose Swift function to Objective C allowing "target/action" model.
    // Objective C has runtime (late) binding: methods calls are represented by a string.
    @objc
    func updateDisplay() {
        
        // Increment array index by 1 yielding traditional 'CD player' 1-based indexing.
        var display = String(format: "Track %d", currentTrack + 1)
        if let metadata = origami.metadata(), let title = metadata["title"] as? String {
            display += " " + title + " "
        }
        display += String(format: "(%1.0f/%1.0f sec)", origami.amountPlayed(), origami.trackTime())
        label.stringValue = display
        seekSlider.doubleValue = origami.amountPlayed()
    }
    
    func playTrack(_ trackNumber: Int) {
        // Calling play() when OrigamiEngine is paused will cause a crash.
        // This might be fixed now.
        // origami.stop()
        if trackNumber < 0 || trackNumber > playlist.count - 1 {
            return
        }
        currentTrack = trackNumber
        trackSelector.selectItem(at: trackNumber)
        origami.play(playlist[currentTrack])
    }
    
    /* Action handlers for buttons */

    @IBAction func ResumeButton(_ sender: AnyObject) {
        origami.resume()
    }
    
    @IBAction func PauseButton(_ sender: AnyObject) {
        origami.pause()
    }

    @IBAction func seek(_ sender: AnyObject) {
        origami.seek(toTime: seekSlider.doubleValue)
    }
    
    @IBAction func trackBack(_ sender: AnyObject) {
        playTrack(currentTrack - 1)
    }
    
    @IBAction func trackForward(_ sender: AnyObject) {
        playTrack(currentTrack + 1)
    }
    
    @IBAction func selectTrack(_ sender: NSPopUpButton) {
        playTrack(sender.indexOfSelectedItem)
    }
    
    
    /* IKImageBrowserDataSource informal protocol. Implemented here because we need to delegate to this instance in the storyboard. */
    
    override func numberOfItems(inImageBrowser aBrowser: IKImageBrowserView!) -> Int {
        return albums.count
    }
    
    override func imageBrowser(_ aBrowser: IKImageBrowserView!, itemAt index: Int) -> Any! {
        return albums[index]
    }

    /* IKImageBrowserDelegate informal protocol. */

    // A double-click on an album cover puts all the album's tracks in the playlist and starts playing the first track
    override func imageBrowser(_ aBrowser: IKImageBrowserView!, cellWasDoubleClickedAt index: Int) {
        let album = albums[index]
        playlist = album.getPlaylist() as [URL]
        let trackTitles = playlist.map { $0.lastPathComponent }
        trackSelector.removeAllItems()
        trackSelector.addItems(withTitles: trackTitles)
        playTrack(0)
    }
    
    /* First Responder action handlers for menus */
    @IBAction func openDocument(_ sender: AnyObject) {
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose root music directory | ABCD";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseDirectories    = true;
        dialog.canChooseFiles          = false;
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            if (result != nil) {
                switchPath(result!.path)
            }
        }
    }
    
    @IBAction func zoomIn(_ sender: AnyObject) {
        if (imageSize < MAX_IMAGE_SIZE) {
            imageSize += IMAGE_SIZE_STEP
            imageBrowser.setCellSize(NSSize(width: imageSize, height: imageSize))
        }
    }

    @IBAction func zoomOut(_ sender: AnyObject) {
        if (imageSize > MIN_IMAGE_SIZE) {
            imageSize -= IMAGE_SIZE_STEP
            imageBrowser.setCellSize(NSSize(width: imageSize, height: imageSize))
        }
    }
    
    /* ORGMEngineDelegate implementation */
    
    // Called when the FLAC library wants to start reading the next file to ensure seamless playback.
    func engineExpectsNextUrl(_ engine: ORGMEngine!) -> URL! {
        currentTrack += 1
        if (currentTrack >= playlist.count) {
            currentTrack = 0
        }
        trackSelector.selectItem(at: currentTrack)
        return playlist[currentTrack]
    }
    
    func engine(_ engine: ORGMEngine!, didChange state: ORGMEngineState) {
        switch state {
        case ORGMEngineStateStopped, ORGMEngineStatePaused:
                timer?.invalidate()
                timer = nil
        case ORGMEngineStatePlaying:
                seekSlider.minValue = 0
                seekSlider.maxValue = origami.trackTime()
                // Create a timer to update the track progress display once per second.
                // Selector in callback must match method signature, including parameters.
                // It would be nice if updates could be smooth, which it is at about 0.1 sec but that uses more CPU.
                if (timer == nil) {
                    timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateDisplay), userInfo: nil, repeats: true)
                }
        case ORGMEngineStateError:
                label.stringValue = engine.currentError.localizedDescription
        default:
                break
        }
    }
    
}

