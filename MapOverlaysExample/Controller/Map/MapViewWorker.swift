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
    func locationIsInsideRegion(location: CLLocationCoordinate2D, areas: [MapPolygon], completion: @escaping (Result<MapPolygon>) -> Void)
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
    
    func locationIsInsideRegion(location: CLLocationCoordinate2D, areas: [MapPolygon], completion: @escaping (Result<MapPolygon>) -> Void) {
        
        if areas.count == 0 {
            completion(Result.noResult)
            return
        }
        
        for area in areas {
            let found = Algorithm.locationInRegionRayCast(location: location, area: area.areaCoordinates)
            if found == true {
                if let insideArea = area.area.interiorPolygons, insideArea.count > 0 {
                    for subArea in insideArea {
                        let foundInSubArea = Algorithm.locationInRegionRayCast(location: location, area: subArea.getCoordinatesArray())
                        if foundInSubArea == true {
                            let subArea = MapPolygon(polygon: subArea)
                            completion(Result.insideRegionInsideSubArea(subArea))
                            return
                        }
                    }
                }

                completion(Result.insideRegion(area))
                return
            }
        }
        completion(Result.outsideRegion)
    }
}
