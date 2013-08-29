MKPolygon+GSPolygonIntersections
================================

#### Author

Chad Saxon (https://github.com/geeksweep/MKPolygon-GSPolygonIntersections)

####Overview

  MKPolygon+GSPolygonIntersections is a MKPolygon category, which provides extra functionality, via some class methods, that you don't have out of the box, namely, advanced geospatial capabilties. Since MKPolygon conforms to MKOverlay, you can add it as an overlay to your map and also use the 'intersectsMapRect:(MKMapRect)' method to see if your MKPolygon intersects a rectangle. 

  However, what if you wanted to test the intersection of your polygon with another non-rectangular polygon and not just a rectangle? What if you wanted to create a brand new MKPolygon based on the union of two non-rectangular MKPolygons? Well if you have then you are in luck because this is what this category actually does! Yep, if you have two MKPolygons already built and you want to get the intersection(union) area of those two polygons then this category will provide that for you. (with certain specific limitations, see below)
  
####Example Screenshots

These are screenshots from a test using the view controller code that is included as part of the project. Basically just a MapView and the view controller to handle all of the GUI stuff. When i am done drawing 2 polygons on the map, I then call the category class method to return to me a new MKPolygon and I use that new polygon as a new overlay (colored orange) on the mapview. (see the view controller code for more details).

Basic MapView 
![screenshot](http://geeksweep.files.wordpress.com/2013/06/screenshot-2013-06-25-13-46-46.png)

Drawing First Polygon 
![screenshot](http://geeksweep.files.wordpress.com/2013/06/screenshot-2013-06-25-13-48-32.png)

Finished Drawing First Polygon
![screenshot](http://geeksweep.files.wordpress.com/2013/06/screenshot-2013-06-25-13-48-50.png)

Now drawing Polygon 2
![screenshot](http://geeksweep.files.wordpress.com/2013/06/screenshot-2013-06-25-13-49-28.png)

Finished Drawing Polygon 2 and the Category does its dirty work.
It then returns the intersected polygon back to the view controller and I add that overlay to the MapView and voila!
![screenshot](http://geeksweep.files.wordpress.com/2013/06/screenshot-2013-06-25-13-49-43.png)

####License

  MKPolygon+GSPolygonIntersections is available under the MIT license. See the License file for more information.
  

####Contents

  There are additional contents available to you with the project. The XCode project file is included if you just want to check it out (no pun intended) and load it into XCode and see how things work. With that, of course, you get the .xib file and the view controller code which builds the two MKPolygons on a MKMapView. I have left some comments in the source code but if you have any questions just let me know! 
  
####Usage

  Once you have your MKPolygons built, all you have to do then is use the category to do all the hard work!
  
  	MKPolygon *intersectedPolygon;
	intersectedPolygon = [MKPolygon polygon:polygon1 intersectedWithSecondPolygon:polygon2];
  
  If you don't know how to create MKPolygons from a MKMapView then please look at the view controller code to see how you can do that. The view controller code isn't complete or perfect and you can add your own functionality (like clearing your polygons and starting over or editing your polygons). I mainly was just using it as a way to visually test my internal logic and code. Again, if you have any questions then let me know! 
  

####Limitations

  This is a list of the following limitations to be aware of and some of these will be fixed in the future. 
  
  1. Supports only counter-clockwise direction. If you build your polygons in a clockwise direction then you won't get the correct results. Adding an extra parameter to the class method that accepts a clockwise direction might be a partial fix but an epic solution would be to support polygons built in any direction. (i.e. Polygon 1 built in a counter-clockwise direction and Polygon 2 built in a clockwise direction). 
  
  2. Does not support "holes" in the polygons. An example would be to have an enclosed polygon with a big cutout in the middle, i.e. doughnut hole.
  
  3. Does not support building the union of two polygons as an array of MKPolygons(if needed). There are cases where two polygons intersect more than once across an area(a gap) where both polygon paths do not cover. The correct result would actually yield two separate MKPolygons not connected to each other in any way. There would have to be logic added to handle these situations and ultimately the category return an array of MKPolygons. 
  
  4. Does not support polygons intersecting themselves. Self-intersecting geometry is considered invalid and most, if not all, 3rd party software doesn't support it.





