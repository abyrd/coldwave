//
//  SingleAlbumView.swift
//  Coldwave
//
//  Created by Andrew Byrd on 3/10/2021.
//
import SwiftUI
import Foundation

struct SingleAlbumView : View, Equatable {

    let album: Album
    let coverSize: CGFloat
    let selected: Bool

    var body: some View {
        VStack {
            let _ = print("Computing one SingleAlbumView for \(album.title)")
            Image(nsImage: album.cover)
                .resizable()
                .frame(width: coverSize, height: coverSize, alignment: .center)
                .border(Color.black.opacity(selected ? 0.8 : 0.3), width: selected ? 2 : 1)
                .shadow(radius: selected ? 10 : 5)
            // Ideally name would be vertically oriented beside album cover, like spine text, but
            // using HStack with Text().rotationEffect(Angle(degrees: -90)) causes misalignment
            Text(album.artist).bold()
            Text(album.title).italic()
        }
    }
    
    // Only re-render this view if the path or cover size change. I'm not even strictly sure about the size.
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.album == rhs.album && lhs.coverSize == rhs.coverSize && lhs.selected == rhs.selected
    }

}
