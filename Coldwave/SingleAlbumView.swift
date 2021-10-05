import Foundation
import SwiftUI

struct SingleAlbumView : View, Equatable {
   
    let album: Album
    let size: CGFloat

    var body: some View {
        VStack {
            // let _ = print("Computing one SingleAlbumView for \(album.title)")
            Image(nsImage: album.cover)
                .resizable()
                // This is not properly handling non-square cover images.
                .frame(width: size, height: size, alignment: .center)
                .aspectRatio(1, contentMode: .fit)
                .border(Color.black, width: 1)
                // Shadow on cover only, not text.
                .shadow(radius: 5)
            // Ideally name would be vertically oriented beside album cover, like spine text, but
            // using HStack with Text().rotationEffect(Angle(degrees: -90)) causes misalignment
            Text(album.artist).bold()
            Text(album.title).italic()
        }
    }

    static func == (lhs: SingleAlbumView, rhs: SingleAlbumView) -> Bool {
        lhs.album === rhs.album && lhs.size == rhs.size
    }

}
