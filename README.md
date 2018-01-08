# MapOverlaysExample
Example to test if a pin located inside some area and to find the nearest location point if a pin located outside of some area

A sample to experiment with:
- Check if the pin is located inside or outside overlay area
- If the pin located outside, find the nearest location point on the overlay area perimeter and calculate the distance between

For detection if a point located inside/outside area, the builtin  CGPath.contains(CGPoint) function was used.

Other algorithms  are included:
1. Ray casting, Winding Number

The sample provide an option to load KML data by selecting different map file in kml format
1. Allowed area
2. Bad example
3. Multiple areas (to test on multiple polygon areas)
4. With holes (Interior polygon areas)


[ with help of KML generate tool from Google Maps API v3 Tool: http://www.birdtheme.org/useful/v3tool.html ]

How to use:
1.  App will load sample KML file "Allowed area" when started.
2. Tap on desired location, inside or outside polygon area to put a pin. Pin color states described below. If a pin located outside a polygon area, the distance between blue and orange pins will be calculated and shown at the bottom toolbar

Pin color states:
- Red color  - Pin located inside the polygon area
- Blue color - Pin located outside the polygon area
- Orange color - Second pin to show the nearest point location on the polygon side to the blue pin

Research resources:
- https://stackoverflow.com/questions/28023272/find-nearest-point-in-polyline-path
- https://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment/11172574#11172574
- http://alienryderflex.com/polygon/
- https://gis.stackexchange.com/questions/16414/point-in-polygon-algorithm-for-multiple-polygons
- https://wrf.ecse.rpi.edu//Research/Short_Notes/pnpoly.html
- https://stackoverflow.com/questions/217578/how-can-i-determine-whether-a-2d-point-is-within-a-polygon

Developed using Xcode 9.2, iOS 10.3, swift 3.2
