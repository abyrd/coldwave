import SwiftUI

@main
struct ColdwaveApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var state: ColdwaveState = ColdwaveState()
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        WindowGroup {
            ContentView(state: state)
        }
        .commands {
            CommandGroup(before: CommandGroupPlacement.newItem) {
                Button(action: { openFolder() }, label: { Label("Open directory...", systemImage: "doc") })
                    .keyboardShortcut("o")

                Button(action: { openWindow(id: "open-location") }, label: { Label("Open location...", systemImage: "doc")})
                    .keyboardShortcut("l")
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

        Window("Open location", id: "open-location") {
            LocationView()
        }.windowResizability(.contentSize)
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

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let unwantedMenus = ["Edit","View"  ]

        let removeMenus = {
            unwantedMenus.forEach {
                guard let menu = NSApp.mainMenu?.item(withTitle: $0) else { return }
                NSApp.mainMenu?.removeItem(menu)
            }
        }

        NotificationCenter.default.addObserver(
            forName: NSMenu.didAddItemNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Must refresh after every time SwiftUI re adds
            removeMenus()
        }

        removeMenus()
    }
}
