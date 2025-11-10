import CoreGPX
import Foundation
internal import _LocationEssentials

class GpxRepository {
    
    enum GPXExportError: Error {
        case noLocations
    }
    
    /// Exports a Trail object to a GPX file and returns the file URL.
    /// - Parameter trail: The Trail object to export.
    /// - Throws: GPXExportError.noLocations if the trail has no valid locations.
    /// - Returns: The URL of the saved GPX file.
    func exportTrailToGPX(_ trail: Trail) throws -> URL {
        // Check if the trail has valid sortedCLLocations
        let locations = trail.locations
        guard !locations.isEmpty else {
            throw GPXExportError.noLocations
        }
        
        // Create a GPX root object with creator "TrailSync"
        let root = GPXRoot(creator: trail.name)
        
        // Add metadata to the GPX file
        let metadata = GPXMetadata()
        metadata.name = trail.name
        metadata.time = trail.timestamp
        metadata.author = GPXAuthor(name: "TrailSync", email: nil, link: GPXLink(withHref: "https://github.com/matvdg/TrailSync/wiki"))
        root.metadata = metadata
        
        // Create a GPX track and a track segment
        let track = GPXTrack()
        let segment = GPXTrackSegment()
        
        // Convert each CLLocation to a GPXTrackPoint and add it to the segment
        for location in locations {
            let trackPoint = GPXTrackPoint(elevation: location.altitude, time: location.date, latitude: location.latitude,
                                           longitude: location.longitude)
            segment.add(trackpoint: trackPoint)
        }
        
        // Add the segment to the track and the track to the root
        track.add(trackSegment: segment)
        root.add(track: track)
        
        // Save the GPX file to the temporary directory
        // tmp/ allows sharing (Files, AirDrop, Mail) because iOS grants temporary access to this directory.
        let tmpDirectory = FileManager.default.temporaryDirectory
        let fileName = "trail_\(UUID().uuidString)"
        let directoryURL = tmpDirectory.appendingPathComponent("trails")
        
        // Ensure the directory exists
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        
        // CoreGPX expects a directory path, not a file path
        try root.outputToFile(saveAt: directoryURL, fileName: fileName)
        
        let fileURL = directoryURL.appendingPathComponent("\(fileName).gpx")
        print(fileURL)
        
        print(directoryURL)
        
        return fileURL
    }
}
