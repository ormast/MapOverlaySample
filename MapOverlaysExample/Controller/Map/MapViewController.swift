//
//  MapViewController.swift
//  MapOverlaysExample
//
//  Created by Oleg B. on 03/01/2018.
//  Copyright © 2018 Oleg B. All rights reserved.
//

import UIKit
import MapKit

enum PinColorState: String {
    case inside = "Red"
    case outside = "Blue"
    case near = "Orange"
}

class MapViewController: UIViewController {
    
    // Distance label
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        return label
    }()
    
    var distance: String? {
        didSet {
            if let text = distance {
                self.distanceLabel.text = "Distance: \(text)"
                self.distanceLabel.sizeToFit()
            }
        }
    }
    
    let mapView: MKMapView = MKMapView()
    let worker: MapViewWorker = MapViewWorker.shared
    
    var nearestSegment: MKPolyline?
    // Pins
    let tappedLocation = MKPointAnnotation()
    let nearestPoint = MKPointAnnotation()
    
    // Array of map polygons
    var mapPolygons = [MapPolygon]()
    
    // Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureMap()
        
        let sampleKML = "Allowed_area"
        loadSampleKML(filename: sampleKML)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // Load KML sample data to the mapView
    func loadSampleKML(filename: String) {
        worker.loadParsedData(name: filename, completion: { (overlays) in
            // process overlays
            if let overlays = overlays {
                DispatchQueue.global().async {
                    
                    self.mapPolygons = []
                    
                    for overlay in overlays {
                        if let polygon = overlay as? MKPolygon {
                            let newPolygon = MapPolygon(polygon: polygon)
                            self.mapPolygons.append(newPolygon)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.mapCleanUp()
                        self.mapAddPolygons()
                    }
                }
            }
        })
    }
    
    // Delegate
    func didSelectKMLFile(name: String?) {
        if let fileName = name {
            loadSampleKML(filename: fileName)
        }
    }
    
    // Clean mapView
    fileprivate func mapCleanUp() {
        self.distance = "0"
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.removeOverlays(self.mapView.overlays)
    }
    
    // Add overlays
    fileprivate func mapAddPolygons() {
        let polygons = self.mapPolygons.map { $0.area }
        
        let centerMap = getBoundingRectFor(overlays: polygons)
        self.mapView.addOverlays(polygons)
        
        // Center map on all objects
        self.mapView.setVisibleMapRect(centerMap, edgePadding: UIEdgeInsets.init(top: 50, left: 50, bottom: 50, right: 50), animated: true)
    }
}

// MARK: MapView Delegates
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if overlay.isKind(of: MKPolygon.self) {
            let rendered = MKPolygonRenderer(overlay: overlay)
            rendered.fillColor = UIColor.blue
            rendered.alpha = 0.4
            return rendered
        }
        
        if overlay.isKind(of: MKPolyline.self) {
            let rendered = MKPolylineRenderer(overlay: overlay)
            rendered.strokeColor = UIColor.green
            rendered.lineWidth = 2
            return rendered
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let pinView = MKPinAnnotationView()
        
        if let pinTitle = annotation.title {
            switch pinTitle ?? "" {
            case PinColorState.inside.rawValue:
                pinView.pinTintColor = UIColor.red
            case PinColorState.outside.rawValue:
                pinView.pinTintColor = UIColor.blue
            case PinColorState.near.rawValue:
                pinView.pinTintColor = UIColor.orange
            default:
                pinView.pinTintColor = UIColor.black
            }
        }
        return pinView
    }
}

// MARK: Event actions
extension MapViewController {
    // Handle Load KML Button
    func loadKMLButtonPressed() {
        let controller = KMLListViewController()
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }

    // Handle Tap gesture
    func handleTapGesture(gesture: UITapGestureRecognizer) {
        
        if self.mapPolygons.count == 0 { return }

        // Remove old data
        self.mapView.removeAnnotation(self.tappedLocation)
        self.mapView.removeAnnotation(self.nearestPoint)
        if let segment = self.nearestSegment { self.mapView.remove(segment) }
        self.distance = "0"
        
        let touchedLocation = gesture.location(in: self.mapView)
        let locationCoord = self.mapView.convert(touchedLocation, toCoordinateFrom: self.mapView)
        tappedLocation.coordinate = locationCoord
        
        // Check if the location pin is placed inside some polygon area
        let isLocationInsideArea = worker.locationIsInside(location: locationCoord, areas: self.mapPolygons)
        if isLocationInsideArea == true {
            // Pin is inside in some polygon area. Place the red pin
            tappedLocation.title = PinColorState.inside.rawValue
            self.mapView.addAnnotation(self.tappedLocation)
            return
        }

        // The pin located outside a polygon areas. Find the nearest polygon area location to the pin
        worker.findNearestLocation(to: tappedLocation.coordinate, areas: self.mapPolygons) {
            (nearestLocation, nearestSegmentCoordinates) -> Void in
            
            // Add nearest location. Place orange pin
            nearestPoint.title = PinColorState.near.rawValue
            nearestPoint.coordinate = nearestLocation
            self.mapView.addAnnotation(self.nearestPoint)
            
            // Add nearest segment and mark on polygon area
            nearestSegment = MKPolyline(coordinates: nearestSegmentCoordinates, count: nearestSegmentCoordinates.count)
            self.mapView.add(nearestSegment!)
            
            // Get distance in meters and convert to km
            let distance = CLLocationDistance.distanceBetweenCoordinates(self.tappedLocation.coordinate, b: self.nearestPoint.coordinate)
            let distanceInKm = LengthFormatter().string(fromValue: distance/1000, unit: LengthFormatter.Unit.kilometer)
            self.distance = distanceInKm
            
            // Place blue pin for tapped location.
            tappedLocation.title = PinColorState.outside.rawValue
            self.mapView.addAnnotation(self.tappedLocation)
        }
    }
}

// MARK: Configuration
extension MapViewController {
    fileprivate func configureView() {
        view.backgroundColor = UIColor.white
        view.addSubview(mapView)
        
        let bottomBar = UIToolbar()
        
        // Bottom ToolBar
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(customView: self.distanceLabel))
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))
        items.append(UIBarButtonItem(title: "Load KML", style: .plain, target: self, action: #selector(loadKMLButtonPressed)))
        bottomBar.items = items
        view.addSubview(bottomBar)
        
        // Constrains. MapView
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.topAnchor.constraint(equalTo: mapView.bottomAnchor)
            ])
        
        // Constrains. Bottom ToolBar
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    fileprivate func configureMap() {
        // MapView configuration
        self.mapView.showsUserLocation = true
        self.mapView.showsPointsOfInterest = true
        self.mapView.showsBuildings = true
        self.mapView.showsCompass = false
        self.mapView.delegate = self
        
        // Add Tap Gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(gesture:)))
        tap.numberOfTapsRequired = 1
        self.mapView.addGestureRecognizer(tap)
    }
}
