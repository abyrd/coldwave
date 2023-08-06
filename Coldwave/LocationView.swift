//
//  LocationView.swift
//  Coldwave
//
//  Created by Raffaele Sena on 7/31/23.
//

import SwiftUI

struct LocationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var location : String = ""

    var body: some View {
        VStack {
            HStack {
                Text("Location:")
                TextField("Enter location of audio file, stream or playlist", text: $location)
            }
            HStack {
                 Button("Cancel") {
                    location = ""
                    dismiss()
                }
                Button("Open") {
                    print(location)
                    dismiss()
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.all)
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView()
    }
}
