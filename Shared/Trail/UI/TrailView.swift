import SwiftUI
import CoreLocation
internal import UniformTypeIdentifiers

private struct ExportedFile: Identifiable {
    let id = UUID()
    let url: URL
}

struct TrailView: View {
    
    @Bindable var trail: Trail
    
    private let gpxRepository = GpxRepository()
    @State private var exportedGPX: ExportedFile?
    
    var body: some View {
        VStack {
            let locations = trail.locations.toCLLocations()
            NavigationLink {
                WorkoutMapView(coordinates: locations)
            } label: {
                WorkoutMapView(coordinates: locations)
                    .disabled(true)
                    .frame(maxHeight: 200)
            }
            Form {
                TextField("Name", text: $trail.name)
                Label(trail.timestamp.toDateStyleMediumWithTimeString, systemImage: "calendar.badge.clock")
                HStack {
                    trail.workoutActivityType.icon.foregroundStyle(Color.accentColor)
                    Text(trail.totalDistance.toString)
                    Text("•")
                    Text(trail.duration.toDurationString)
                }
                Button {
                    trail.isFav.toggle()
                } label: {
                    Label(trail.isFav ? "RemoveFromFavorites" : "AddToFavorites", systemImage: trail.isFav ? "star.slash" : "star")
                }
            }
            .formStyle(.grouped)
            Spacer()
        }
        .navigationTitle(trail.name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
#if os(macOS)
                HStack {
                    Button {
                        if let url = try? gpxRepository.exportTrailToGPX(trail) {
                            presentShareSheet(with: [url])
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .imageScale(.large)
                    }
                    
                    Button {
                        DispatchQueue.main.async {
                            guard let window = NSApp.keyWindow ?? NSApp.mainWindow else {
                                print("No active window to present save panel.")
                                return
                            }

                            let panel = NSSavePanel()
                            // Ensure exported files use the correct .gpx extension instead of .gpx.xml
                            panel.allowedContentTypes = [UTType(filenameExtension: "gpx")!]
                            panel.nameFieldStringValue = "\(trail.name).gpx"
                            panel.canCreateDirectories = true

                            panel.beginSheetModal(for: window) { response in
                                if response == .OK, let url = panel.url {
                                    do {
                                        let localURL = try gpxRepository.exportTrailToGPX(trail)
                                        let gpxData = try Data(contentsOf: localURL)
                                        try gpxData.write(to: url)
                                    } catch {
                                        print("Error saving GPX:", error)
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .imageScale(.large)
                    }
                }
#else
                Button {
                    if let url = try? gpxRepository.exportTrailToGPX(trail) {
                        exportedGPX = ExportedFile(url: url)
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .imageScale(.large)
                }
#endif
            }
        }
#if os(iOS) || os(visionOS)
        // The share sheet is presented only after the export completes and exportedGPX is set
        .sheet(item: $exportedGPX) { exported in
            ActivityView(activityItems: [exported.url])
        }
#endif
    }
}

#Preview {
    let trail = Trail(name: "Rando", activityType: WorkoutActivity.hiking.id, duration: 3877, totalDistance: 12233, locations: [
        CLLocation(latitude: 42.83191, longitude: 1.03097),
        CLLocation(latitude: 42.82659, longitude: 1.03883),
        CLLocation(latitude: 42.81841, longitude: 1.04140),
        CLLocation(latitude: 42.80900, longitude: 1.04951),
        CLLocation(latitude: 42.80427, longitude: 1.05286),
        CLLocation(latitude: 42.80031, longitude: 1.05951),
        CLLocation(latitude: 42.79801, longitude: 1.06728),
        CLLocation(latitude: 42.79747, longitude: 1.07239),
        CLLocation(latitude: 42.79527, longitude: 1.07904),
        CLLocation(latitude: 42.79533, longitude: 1.08393)
    ])
    NavigationStack {
        TrailView(trail: trail)
    }
}

#if os(iOS) || os(visionOS)
import UIKit

private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}
#elseif os(macOS)
import AppKit

extension View {
    func presentShareSheet(with items: [Any]) {
        let picker = NSSharingServicePicker(items: items)
        if let window = NSApplication.shared.keyWindow,
           let contentView = window.contentView {
            picker.show(relativeTo: contentView.bounds, of: contentView, preferredEdge: .minY)
        }
    }
}
#endif
