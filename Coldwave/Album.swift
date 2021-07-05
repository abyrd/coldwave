//
//  Album.swift
//  Coldwave
//
//  Created by Andrew Byrd on 2015-02-01.
//  Copyright (c) 2015, 2016, 2017 Andrew Byrd. All rights reserved.
//

import Foundation
import Quartz

class Album: NSObject {
    
    var coverImagePath: String = ""
    var albumPath: String
    var title: String
    var artist: String
    //var cover: NSImage?

    /* Call with full path to a directory */
    init (_ albumFullPath: String) {
        albumPath = albumFullPath
        let fileManager = FileManager.default
        let contents = try! fileManager.contentsOfDirectory(atPath: albumFullPath)
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
    }

    /*
        let fileManager = NSFileManager.defaultManager()
        let enumerator: NSDirectoryEnumerator = fileManager.enumeratorAtPath(basePath)!
        for element in enumerator.allObjects as [String] {
            println(element)
        }
    */

    
    // TODO use URLs which are more efficient than string paths
    class func scanArtist (_ artistBasePath: String) -> [Album] {
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
    class func scanLibrary (at basePath: String) -> [Album] {
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
        let contents = try! fileManager.contentsOfDirectory(atPath: albumPath)
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
    
    
//    Use these to decide whether to catalog a given directory
//    class func findMusicFiles
//    class func findCoverImages
//    class func findMetadataInDir
    
    /* IKImageBrowserItem informal protocol */

    override func imageUID() -> String! {
        // The full path of the album folder should uniquely identify an Album.
        return albumPath
    }
    
    override func imageRepresentationType() -> String! {
        // The image will be supplied to the browser as a path String.
        return IKImageBrowserPathRepresentationType
    }
    
    override func imageRepresentation() -> Any! {
        return coverImagePath
    }
    
    override func imageTitle() -> String! {
        return title
    }

    override func imageSubtitle() -> String! {
        return artist
    }

}
