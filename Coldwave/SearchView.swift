import Foundation
import SwiftUI

struct SearchView: View {
    
    @ObservedObject var state: ColdwaveState

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search", text: $state.searchText).foregroundColor(.primary)
            Image(systemName: "xmark.circle.fill")
                .opacity(state.searchText == "" ? 0 : 1)
                .onTapGesture { state.searchText = "" }
        }
        .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
        .foregroundColor(.secondary)
        .cornerRadius(10.0)
    }

}
