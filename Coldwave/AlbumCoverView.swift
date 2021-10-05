import SwiftUI
import Foundation

// LazyVGrid is too big to recompute at every interaction
// It has been factored out into an Equatable struct for more efficient updates.
struct AlbumCoverView : View, Equatable {

    let path: String
    let coverSize: CGFloat
    let currentAlbum: Album?
    let state: ColdwaveState // replace with separate ColdwavePlayer class, with play methods.
    let searchText: String
    
    init(state: ColdwaveState) {
        self.state = state
        path = state.path
        coverSize = state.coverSize
        currentAlbum = state.currentAlbum
        searchText = state.searchText
    }
    
    var body: some View {
        ScrollView {
            ScrollViewReader {scrollView in
                // let _ = print("Computing potentially huge ScrollView")
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: coverSize))],
                    spacing: GRID_SPACING
                ){
                    // ForEach with an initial capital F is a SwiftUI view, not the language construct.
                    // Identify albums by their filesystem path which is hashable (it's a String).
                    // Alternatively we could make a struct for a single album cover conforming to Identifiable.
                    ForEach(state.albums.filter({ a in a.matchesSearchTerm(searchText) })) { album in
                        let selected = (state.currentAlbum === album)
                        SingleAlbumView(album: album, size: coverSize)
                            // TODO factor out aspectRatio or frame() call here so highlight and size are both handled in LazyVGrid
                            .background(selected ? Color.accentColor : Color.clear)
                            .onTapGesture(count: 2) {
                                state.jumpToTrack(album: album, trackNumber: 0)
                            }
                    }
                }.padding(PADDING).onAppear() {
                    // Return to selected album on exiting full-window album cover view.
                    // This still doesn't handle the case of losing one's position by resizing.
                    if let ca = currentAlbum {
                        scrollView.scrollTo(ca.albumPath)
                    }
                }
            }
        }
    }

    // Only re-render this view if the path, cover size, or search filter change, or if a different album is selected.
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.path == rhs.path &&
            lhs.coverSize == rhs.coverSize &&
            lhs.currentAlbum === rhs.currentAlbum &&
            lhs.searchText == rhs.searchText
    }

}

