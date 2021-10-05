import SwiftUI
import AVFoundation

let MIN_IMAGE_SIZE: CGFloat = 100
let MAX_IMAGE_SIZE: CGFloat = 800
let IMAGE_SIZE_STEP: CGFloat = 50
let DEFAULT_IMAGE_SIZE: CGFloat = 400
let GRID_SPACING: CGFloat = 20
let PADDING: CGFloat = 10

struct ContentView: View {
    
    @ObservedObject var state: ColdwaveState
    
    var body: some View {
        VStack {
            // Top edge: text box to search artist and album title.
            SearchView(state: state)
            // Center screen: Either a full-size album cover or a scrollable view of all covers if no album is playing.
            if (state.playing) {
                Image(nsImage: state.currentAlbum!.cover)
                    .resizable()
                    .border(Color.black)
                    .aspectRatio(contentMode: .fit)
                    .padding(PADDING)
            } else {
                AlbumCoverView(state: state)
            }
            // Bottom edge: playback and track selection controls.
            PlaybackControlView(state: state)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(state: ColdwaveState())
        }
    }
}

