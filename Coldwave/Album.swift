import Foundation
import Quartz

// Represents a single album (a single filesystem directory containing audio files).
// This is the domain model, not the visual representation as a View.
class Album: Identifiable, Equatable {
    
    static func == (lhs: Album, rhs: Album) -> Bool {
        // Identity equality for Albums. Could also compare albumPaths for consistency with Identifiable
        lhs === rhs
    }
    
    let albumPath: String
    let artist: String
    let title: String
    var coverImagePath: String = ""
    let cover: NSImage

    /* Call with full path to a directory */
    init (_ albumFullPath: String) {
        albumPath = albumFullPath
        let fileManager = FileManager.default
        let contents = try! fileManager.contentsOfDirectory(atPath: albumFullPath).sorted()
        for file in contents as [String] {
            var isDir: ObjCBool = false;
            let lcFile = file.lowercased()
            // fileManager.changeCurrentDirectoryPath("")
            let fullFilePath = NSString.path(withComponents: [albumFullPath, file])
            if fileManager.fileExists(atPath: fullFilePath, isDirectory: &isDir) && !isDir.boolValue {
                if lcFile.hasSuffix(".jpg") || lcFile.hasSuffix(".jpeg") || lcFile.hasSuffix(".png") {
                    self.coverImagePath = fullFilePath
                    if (lcFile.hasPrefix("cover") || lcFile.hasPrefix("600x600")) {
                        break
                    }
                }
            }
        }
        var pathComponents = (albumFullPath as NSString).pathComponents
        title = pathComponents.removeLast()
        artist = pathComponents.removeLast()
        // Cache cover images so they're not reloaded on every SwiftUI update cycle.
        // We could defer this until the image is actually used/displayed with a lazy-initializing property.
        // We could also reuse the NSImages for the placeholder "missing cover" images.
        if (coverImagePath == "") {
            cover = NSImage(named: "record-sleeve-\(abs(title.hashValue % 2)).png")!
        } else {
            cover = NSImage(contentsOfFile: coverImagePath)!
        }
    }

    /*
        let fileManager = NSFileManager.defaultManager()
        let enumerator: NSDirectoryEnumerator = fileManager.enumeratorAtPath(basePath)!
        for element in enumerator.allObjects as [String] {
            println(element)
        }
    */

    // Identifiable protocol - help collection views uniquely identify their subitems
    var id: String { albumPath }
    
    // TODO use URLs which are more efficient than string paths
    static func scanArtist (_ artistBasePath: String) -> [Album] {
        var albums: [Album] = []
        let fileManager = FileManager.default
        let contents = try! fileManager.contentsOfDirectory(atPath: artistBasePath)
        for file in contents as [String] {
            var isDir: ObjCBool = false
            let albumFullPath = NSString.path(withComponents: [artistBasePath, file])
            if fileManager.fileExists(atPath: albumFullPath, isDirectory: &isDir) && isDir.boolValue {
                albums.append(Album(albumFullPath))
            }
        }
        return albums
    }
    

    // Return an array of Album objects for subdirectories under the supplied base directory.
    static func scanLibrary (at basePath: String) -> [Album] {
        var albums: [Album] = []
        let fileManager = FileManager.default
        let contents = try! fileManager.contentsOfDirectory(atPath: basePath)
        for file in contents as [String] {
            var isDir: ObjCBool = false
            let artistBasePath = NSString.path(withComponents: [basePath, file])
            if fileManager.fileExists(atPath: artistBasePath, isDirectory: &isDir) && isDir.boolValue {
                albums += scanArtist(artistBasePath)
            }
        }
        return albums
    }


    // Return an array of URLs, one for each music file in this album's folder.
    func getPlaylist () -> [URL] {
        let fileManager = FileManager.default
        let contents = try! fileManager.contentsOfDirectory(atPath: albumPath).sorted()
        var musicFileURLs: [URL] = []
        for file in contents as [String] {
            let lcFile = file.lowercased()
            let fullFilePath = NSString.path(withComponents: [albumPath, file])
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: fullFilePath, isDirectory: &isDir) && !isDir.boolValue {
                if lcFile.hasSuffix(".flac") || lcFile.hasSuffix(".mp3") || lcFile.hasSuffix(".m4a") {
                    musicFileURLs.append(URL(fileURLWithPath: fullFilePath))
                }
            }
        }
        return musicFileURLs
    }    

    // Return true if the artist or title contains the specified search string, ignoring case and diacritical marks.
    func matchesSearchTerm (_ searchTerm: String) -> Bool {
        // Contains method does not return true for empty string argument.
        searchTerm.isEmpty || artist.localizedStandardContains(searchTerm) || title.localizedStandardContains(searchTerm)
    }
    
    //    We could use these to decide whether to catalog a given directory, allowing more flexible director layout.
    //    class func findMusicFiles
    //    class func findCoverImages
    //    class func findMetadataInDir


}
