import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    var routeCoordinates: [CLLocationCoordinate2D]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
         mapView.showsBuildings = false // Disable 3D buildings
        mapView.isPitchEnabled = false // Disable pitch to keep the map flat
        mapView.isRotateEnabled = false
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Remove existing overlays to avoid duplicates
        mapView.removeOverlays(mapView.overlays)
        
        // Check if there are coordinates to draw
        guard !routeCoordinates.isEmpty else {
            print("No route coordinates available to draw.")
            return
        }
        
        // Create and add the polyline
        let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        mapView.addOverlay(polyline)
        
        // Adjust the map view to fit the polyline
        mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

    }
} 
