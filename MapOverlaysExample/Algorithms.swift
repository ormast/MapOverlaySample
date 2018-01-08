//
//  Algorithms.swift
//  MapOverlaysExample
//
//  Created by Oleg B. on 08/01/2018.
//  Copyright © 2018 Oleg B. All rights reserved.
//

import MapKit
import MapKit
protocol DataProcessingType {
    
    func locationIsInside(shape: [CLLocationCoordinate2D], location: CLLocationCoordinate2D) -> Bool
}

class RayCast: DataProcessingType {
    
    func locationIsInside(shape: [CLLocationCoordinate2D], location: CLLocationCoordinate2D) -> Bool {
        var inside = false
        for i in 0..<shape.count - 1 {
            let xi = shape[i].latitude
            let yi = shape[i].longitude
            let xi2 = shape[i+1].latitude
            let yi2 = shape[i+1].longitude
            
            let intersect = ((yi > location.longitude) != (yi2 > location.longitude)) && (location.latitude < (xi2 - xi) * (location.longitude - yi) / (yi2 - yi) + xi)
            if intersect {
                inside = !inside
            }
        }
        return inside
    }
}

class WindingNumber: DataProcessingType {
    func locationIsInside(shape: [CLLocationCoordinate2D], location: CLLocationCoordinate2D) -> Bool {
        var wn = 0
        
        for i in 0..<shape.count - 1 {
            let coordinate = shape[i]
            let nextCoordinate = shape[i+1]
            if coordinate.latitude <= location.latitude && nextCoordinate.latitude > location.latitude {
                let vt: Double = (location.latitude - coordinate.latitude) / (nextCoordinate.latitude - coordinate.latitude)
                if location.longitude < (coordinate.longitude + (vt * (nextCoordinate.longitude - coordinate.longitude))) {
                    wn = wn + 1
                }
            }
            else if coordinate.latitude > location.latitude && nextCoordinate.latitude <= location.latitude {
                let vt: Double = (location.latitude - coordinate.latitude) / (nextCoordinate.latitude - coordinate.latitude)
                if location.longitude < (coordinate.longitude + (vt * (nextCoordinate.longitude - coordinate.longitude))) {
                    wn = wn - 1
                }
            }
        }
        return wn != 0
    }
    
    /*
     func locationInRegionWN2(location: CLLocationCoordinate2D, area: [CLLocationCoordinate2D]) -> Bool {
     var wn = 0
     for i in 0..<area.count-1 {
     let coordinateA = area[i]
     let coordinateB = area[i+1]
     if coordinateA.longitude <= location.longitude {
     if coordinateB.longitude > location.longitude {
     if  isLeft(a: coordinateA, b: coordinateB, c: location) > 0 {
     wn = wn+1
     }
     }
     }
     else {
     if coordinateB.longitude <= location.longitude {
     if isLeft(a: coordinateA, b: coordinateB, c: location) < 0 {
     wn = wn-1
     }
     }
     }
     }
     return wn != 0
     }
     
     private func isLeft(a: CLLocationCoordinate2D, b: CLLocationCoordinate2D, c: CLLocationCoordinate2D) -> Double {
     let p1 = (b.latitude - a.latitude) * (c.longitude - a.longitude)
     let p2 = (c.latitude - a.latitude) * (b.longitude - a.longitude)
     let p3 = p1 - p2
     return p3
     }
     */
}

class PathContains: DataProcessingType {
    func locationIsInside(shape: [CLLocationCoordinate2D], location: CLLocationCoordinate2D) -> Bool {
        let polygon = MKPolygon(coordinates: shape, count: shape.count)
        return locationIsInside(location: location, polygon: polygon)
    }
    
    private func locationIsInside(location: CLLocationCoordinate2D, polygon: MKPolygon) -> Bool {
        let result = polygon.contains(coordinate: location)
        if result == true { return true }
        return false
    }
    
    /*
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
     */
}

class Algorithm {
    
    var type: DataProcessingType
    
    init(type: DataProcessingType) {
        self.type = type
    }
    
    func findIfLocationIsInArea(location: CLLocationCoordinate2D, area: [CLLocationCoordinate2D]) -> Bool {
        return type.locationIsInside(shape: area, location: location)
    }
}
