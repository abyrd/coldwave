import SwiftUI

@main
struct ColdwaveApp: App {
    
    @StateObject var state: ColdwaveState = ColdwaveState()
    
    var body: some Scene {
        WindowGroup {
            ContentView(state: state)
        }
        .commands {
            CommandGroup(before: CommandGroupPlacement.newItem) {
                Button(action: { openFolder() }, label: { Label("Open directory...", systemImage: "doc") })
                    .keyboardShortcut("o")
            }
            CommandMenu("Utilities") {
                Button("Bigger") {
                    if (state.coverSize < MAX_IMAGE_SIZE) { state.coverSize += IMAGE_SIZE_STEP }
                }.keyboardShortcut("+")
                Button("Smaller") {
                    if (state.coverSize > MIN_IMAGE_SIZE) { state.coverSize -= IMAGE_SIZE_STEP }
                }.keyboardShortcut("-")
            }
        }
    }
    
    private func openFolder () {
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
                state.path = result!.path;
                // Change this, it should happen automatically on state update
                state.albums = Album.scanLibrary(at: state.path)
            }
        }
    }

}
