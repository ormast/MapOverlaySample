//
//  Extensions.swift
//  MapOverlaysExample
//
//  Created by Oleg B. on 03/01/2018.
//  Copyright © 2018 Oleg B. All rights reserved.
//

import MapKit

extension CLLocationDistance {
    
    // Get distance between the two coordinates
    static func distanceBetweenCoordinates(_ a: CLLocationCoordinate2D, b: CLLocationCoordinate2D) -> CLLocationDistance {
        let locationA: CLLocation = CLLocation(latitude: a.latitude, longitude: a.longitude)
        let locationB: CLLocation = CLLocation(latitude: b.latitude, longitude: b.longitude)
        
        return locationA.distance(from: locationB)
    }
}

extension CGPoint {
    
    // Get the hypotenuse defined by the two
    static func hypotenuse(_ a: CGPoint, b: CGPoint) -> Double {
        return Double(hypot(b.x - a.x, b.y - a.y))
    }
    
    static func findNearestPointTo(_ origin: CGPoint,
                                   onSegmentPointA pointA: CGPoint,
                                   pointB: CGPoint,
                                   distance: inout Float) -> CGPoint {
        let dAP = CGPoint(x: origin.x - pointA.x, y: origin.y - pointA.y);
        let dAB = CGPoint(x: pointB.x - pointA.x, y: pointB.y - pointA.y);
        let dot: CGFloat  = dAP.x * dAB.x + dAP.y * dAB.y;
        let squareLength: CGFloat  = dAB.x * dAB.x + dAB.y * dAB.y;
        let param: CGFloat  = dot / squareLength;
        
        var nearestPoint = CGPoint.zero
        if (param < 0 || (pointA.x == pointB.x && pointA.y == pointB.y)) {
            nearestPoint.x = pointA.x;
            nearestPoint.y = pointA.y;
        } else if (param > 1) {
            nearestPoint.x = pointB.x;
            nearestPoint.y = pointB.y;
        } else {
            nearestPoint.x = pointA.x + param * dAB.x;
            nearestPoint.y = pointA.y + param * dAB.y;
        }
        
        let dx: CGFloat  = origin.x - nearestPoint.x;
        let dy: CGFloat  = origin.y - nearestPoint.y;
        distance = sqrtf(Float(dx * dx) + Float(dy * dy))
        
        return nearestPoint;
    }
}

extension MKPolygon {
    // Check if the location placed inside or outside of MKPolygon area
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        let polyRendered = MKPolygonRenderer(polygon: self)
        let currentMapPoint: MKMapPoint = MKMapPointForCoordinate(coordinate)
        let polygonViewPoint: CGPoint = polyRendered.point(for: currentMapPoint)
        return polyRendered.path.contains(polygonViewPoint)
    }
}

extension MKMultiPoint {
    // Return list of MKShape shape coordinates
    func getCoordinatesArray() -> [CLLocationCoordinate2D] {
        var coords: [CLLocationCoordinate2D] = Array(repeating: CLLocationCoordinate2D(), count: self.pointCount)
        self.getCoordinates(&coords, range: NSMakeRange(0, self.pointCount))
        return coords
    }
}

// Return rect bounds for all overlays
func getBoundingRectFor(overlays: [MKOverlay]) -> MKMapRect {
        
    if overlays.count == 0 { return MKMapRectNull }
    
    var rectBound = MKMapRectNull
    for overlay in overlays {
        if MKMapRectIsNull(rectBound) {
            rectBound = overlay.boundingMapRect
        }
        else {
            rectBound = MKMapRectUnion(rectBound, overlay.boundingMapRect)
        }
    }
    return rectBound
}
