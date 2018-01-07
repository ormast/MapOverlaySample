//
//  MapViewWorker.swift
//  MapOverlaysExample
//
//  Created by Oleg B. on 03/01/2018.
//  Copyright © 2018 Oleg B. All rights reserved.
//

import UIKit
import MapKit

protocol ParsedDataLoading {
    func loadParsedData(name filename: String, completion: @escaping ([MKOverlay]?) -> Void)
}

protocol MapDataProcessing {
    func findNearestLocation(to coordinate: CLLocationCoordinate2D,
                                areas: [MapPolygon],
                                completion: (CLLocationCoordinate2D, [CLLocationCoordinate2D]) -> Void)
    func locationIsInside(location: CLLocationCoordinate2D, areas: [MapPolygon]) -> Bool
}

class MapViewWorker {
    
    static let shared = MapViewWorker()
}

extension MapViewWorker: ParsedDataLoading {
    
    func loadParsedData(name filename: String, completion: @escaping ([MKOverlay]?) -> Void) {
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: "kml") else {
            completion(nil)
            return
        }
        
        let kmlParser = KMLParser(url: url)
        kmlParser.parseKML()
        let overlays = kmlParser.overlays
        completion(overlays)
    }
}

extension MapViewWorker: MapDataProcessing {
    // Find nearest location to the coordinate
    // https://stackoverflow.com/questions/28023272/find-nearest-point-in-polyline-path
    func findNearestLocation(to coordinate: CLLocationCoordinate2D,
                                             areas: [MapPolygon],
                                             completion: (CLLocationCoordinate2D, [CLLocationCoordinate2D]) -> Void) {
        
        var nearestPoint: CGPoint = CGPoint.zero
        var bestDistance: Float = .greatestFiniteMagnitude
        let originPoint: CGPoint = CGPoint(x: coordinate.longitude, y: coordinate.latitude)
        var bestSegmentCoordinates = [CLLocationCoordinate2D]()
        
        for polygon in areas {
            // We accept only polygon
            if polygon.areaCoordinates.count > 3 {
                
                for index in 0..<polygon.areaCoordinates.count - 1 {
                    let startCoord = polygon.areaCoordinates[index] as CLLocationCoordinate2D
                    let endCoord = polygon.areaCoordinates[index+1] as CLLocationCoordinate2D
                    
                    let startPoint = CGPoint(x: startCoord.longitude, y: startCoord.latitude)
                    let endPoint = CGPoint(x: endCoord.longitude, y: endCoord.latitude)
                    var distance: Float = 0.0
                    
                    let point = CGPoint.findNearestPointTo(originPoint, onSegmentPointA: startPoint, pointB: endPoint, distance: &distance)
                    if (distance < bestDistance) {
                        bestDistance = distance;
                        nearestPoint = point;
                        bestSegmentCoordinates = [startCoord, endCoord]
                    }
                }
            }
        }
        
        let bestLocation = CLLocationCoordinate2DMake(CLLocationDegrees(nearestPoint.y), CLLocationDegrees(nearestPoint.x))
        completion(bestLocation, bestSegmentCoordinates)
    }
    
    // Check if the location is inside or outside of the areas
    func locationIsInside(location: CLLocationCoordinate2D, areas: [MapPolygon]) -> Bool {
        for polygon in areas {
            let result = polygon.area.contains(coordinate: location)
            if result == true { return true }
        }
        return false
    }
    
    // 2 Not used in the sample
    func containsPoint(in polygon: [CGPoint], point: CGPoint) -> Bool {
        if polygon.count <= 1 {
            return false
        }
        
        let p = UIBezierPath()
        let firstPoint = polygon[0] as CGPoint
        
        p.move(to: firstPoint)
        
        for index in 1...polygon.count-1 {
            p.addLine(to: polygon[index] as CGPoint)
        }
        
        p.close()
        
        return p.contains(point)
    }
}
