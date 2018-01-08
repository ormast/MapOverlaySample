//
//  Algorithms.swift
//  MapOverlaysExample
//
//  Created by Oleg B. on 08/01/2018.
//  Copyright © 2018 Oleg B. All rights reserved.
//

import MapKit

class Algorithm {
    
    static func locationInRegionRayCast(location: CLLocationCoordinate2D, area: [CLLocationCoordinate2D]) -> Bool {
        var inside = false
        for i in 0..<area.count - 1 {
            let xi = area[i].latitude
            let yi = area[i].longitude
            let xi2 = area[i+1].latitude
            let yi2 = area[i+1].longitude
            
            let intersect = ((yi > location.longitude) != (yi2 > location.longitude)) && (location.latitude < (xi2 - xi) * (location.longitude - yi) / (yi2 - yi) + xi)
            if intersect {
                inside = !inside
            }
        }
        return inside
    }

    static func locationInRegionWN(location: CLLocationCoordinate2D, area: [CLLocationCoordinate2D]) -> Bool {
    
        var wn = 0
    
        for i in 0..<area.count - 1 {
            let coordinate = area[i]
            let nextCoordinate = area[i+1]
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

    static func locationInRegionWN2(location: CLLocationCoordinate2D, area: [CLLocationCoordinate2D]) -> Bool {
        var wn = 0
        for i in 0..<area.count-1 {
            let coord1 = area[i]
            let coord2 = area[i+1]
            if coord1.longitude <= location.longitude {
                if coord2.longitude > location.longitude {
                    if  isLeft(a: coord1, b: coord2, c: location) > 0 {
                        wn = wn+1
                    }
                }
            }
            else {
                if coord2.longitude <= location.longitude {
                    if isLeft(a: coord1, b: coord2, c: location) < 0 {
                        wn = wn-1
                    }
                }
            }
        }
        return wn != 0
    }

    static private func isLeft(a: CLLocationCoordinate2D, b: CLLocationCoordinate2D, c: CLLocationCoordinate2D) -> Double {
        let p1 = (b.latitude - a.latitude) * (c.longitude - a.longitude)
        let p2 = (c.latitude - a.latitude) * (b.longitude - a.longitude)
        let p3 = p1 - p2
        return p3
    }

    static func locationIsInside(location: CLLocationCoordinate2D, areas: [MapPolygon]) -> Bool {
        for polygon in areas {
            let result = polygon.area.contains(coordinate: location)
            if result == true { return true }
        }
        return false
    }

    static func containsPoint(in polygon: [CGPoint], point: CGPoint) -> Bool {
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
