//
//  MapArea.swift
//  MapOverlaysExample
//
//  Created by Oleg B. on 03/01/2018.
//  Copyright © 2018 Oleg B. All rights reserved.
//

import MapKit

struct MapPolygon {
    let area: MKPolygon
    let areaCoordinates: [CLLocationCoordinate2D]
    
    init(polygon: MKPolygon) {
        self.area = polygon
        self.areaCoordinates = polygon.getCoordinatesArray()
    }
}
