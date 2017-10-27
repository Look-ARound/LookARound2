//
//  AugmentedViewController.swift
//  lookaround2
//
//  Created by Angela Yu on 10/21/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//  Forked from MapBox + ARKit by MapBox at https://github.com/mapbox/mapbox-arkit-ios
//

import UIKit
import ARKit
import SceneKit
import CoreLocation

import FacebookCore
import FacebookLogin

import Mapbox
import MapboxDirections
import MapboxARKit
import Turf

class AugmentedViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var controlsContainerView: UIView!
    @IBOutlet weak var mapView: MGLMapView!
    var mapTop: NSLayoutConstraint!
    var mapBottom: NSLayoutConstraint!
    
    @IBOutlet weak var moreControl: UISegmentedControl!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Use this to control how ARKit aligns itself to the world
    // Often ARKit can determine the direction of North well enough for
    // the demo to work. However, its accuracy can be poor and it can
    // often make more sense to manually help the demo calibrate by starting
    // app while facing North. If you do that, change this setting to false
    var automaticallyFindTrueNorth = true
    
    // Create an instance of MapboxDirections to simplify querying the Mapbox Directions API
    let directions = Directions.shared
    var annotationManager: AnnotationManager!
    
    // Define a shape collection that will be used to hold the point geometries that define the
    // directions routeline
    var waypointShapeCollectionFeature: MGLShapeCollectionFeature?
    
    var currentLocation: CLLocation {
        get {
            guard let userLocation = mapView.userLocation, let coreLocation = userLocation.location else {
                print("no location")
                return CLLocation(latitude: -180.0, longitude: -180.0)
            }
            return coreLocation // SETLOCATION(1/2) uncomment this line to use actual current location
            //return CLLocation(latitude: 37.7837851, longitude: -122.4334173) // uncomment this line to use SF location
            //return CLLocation(latitude: 35.6600201, longitude: 139.697973) // uncomment this line to use Tokyo location
            //return CLLocation(latitude: 40.7408932, longitude: -74.0070035) // uncomment this line to use NYC location
            //return CLLocation(latitude: 36.1815789, longitude: -86.7348512) // uncomment this line to use Nashville location
            //return CLLocation(latitude: 23.7909714, longitude: 90.4014137) // uncomment this line to use Dhaka location
        }
    }
    
    var currentCoordinates: CLLocationCoordinate2D {
        get {
            return currentLocation.coordinate
        }
    }
    
    var placeArray: [Place]?
    var numResults = 10

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure and style the 2D map view
        configureMapboxMapView()
        
        // SceneKit
        // sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.scene = SCNScene()
        
        // Create an AR annotation manager and give it a reference to the AR scene view
        annotationManager = AnnotationManager(sceneView: sceneView)
        annotationManager.delegate = self
        
        // Set up the UI elements as per the app theme
        filterButton.setImage(#imageLiteral(resourceName: "hamburger-on"), for: .selected)
        prepButtonsWithARTheme(buttons: [mapButton])
        moreControl.selectedSegmentIndex = 0
        
        searchBar.delegate = self
        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundColor = UIColor.clear
        searchBar.tintColor = UIColor.clear
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        
        initMap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Start the AR session
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - SearchBar methods
        
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            // Fetch places
            PlaceSearch().fetchPlaces(with: searchText, success: { (places: [Place]?) in
                if let places = places {
                    self.removeExistingPins()
                    self.addPlaces(places: places)
                }
            }, failure: { (error: Error) in
                print("error fetching places based on search term: \(searchText). Error: \(error)")
            })
        }
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    // MARK: - 2D Map setup
    func initMap()
    {
        mapView.alpha = 0.9
        
        controlsContainerView.translatesAutoresizingMaskIntoConstraints = false
        mapTop = controlsContainerView.topAnchor.constraint(equalTo: view.centerYAnchor)
        mapTop.isActive = true
        mapBottom = controlsContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        mapBottom.isActive = true
        
        // Move mapView offscreen (below view)
        self.view.layoutIfNeeded() // Do this, otherwise frame.height will be incorrect
        mapTop.constant = mapView.frame.height
        mapBottom.constant = mapView.frame.height
    }
    
    func isMapHidden() -> Bool {
        return !(self.mapBottom?.constant == 0)
    }
    
    private func configureMapboxMapView() {
        mapView.delegate = self
        mapView.styleURL = MGLStyle.streetsStyleURL()
        mapView.userTrackingMode = .followWithHeading
        mapView.layer.cornerRadius = 10
        
        // SETLOCATION(2/2) Comment all these lines out to use actual current location
        // Uncomment this line to use SF location
        //mapView.setCenter(CLLocationCoordinate2DMake(37.7837851, -122.4334173), zoomLevel: 12, animated: true)
        
        // Uncomment this line to use Tokyo location
        //mapView.setCenter(CLLocationCoordinate2DMake(35.6600201, 139.697973), zoomLevel: 15, animated: true)
        
        // Uncomment this line to use NYC location
        //mapView.setCenter(CLLocationCoordinate2DMake(40.7408932, -74.0070035), zoomLevel: 14, animated: true)
        
        // Uncomment this line to use Nashville location
        //mapView.setCenter(CLLocationCoordinate2DMake(36.1815789, -86.7348512), zoomLevel: 14, animated: true)
        
        // Uncomment this line to use Dhaka location
        //mapView.setCenter(CLLocationCoordinate2DMake(23.7909714, 90.4014137), zoomLevel: 14, animated: true)
    }
    
    // MARK: - AR scene setup
    
    private func startSession() {
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        if automaticallyFindTrueNorth {
            configuration.worldAlignment = .gravityAndHeading
        } else {
            configuration.worldAlignment = .gravity
        }
        
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking])
    }
    
    private func prepButtonsWithARTheme(buttons : [UIButton]) {
        for button in buttons {
            button.tintColor = UIColor.LABrand.primary
            button.setTitleColor(UIColor.LABrand.primary, for: .normal)
            button.layer.cornerRadius = button.frame.size.height * 0.5
            button.clipsToBounds = true
            button.alpha = 0.6
        }
        filterButton.tintColor = UIColor.LABrand.unselected
        filterButton.clipsToBounds = true
        filterButton.alpha = 0.6
        moreControl.tintColor = UIColor.LABrand.accent
        moreControl.backgroundColor = UIColor.white
        moreControl.clipsToBounds = true
        moreControl.alpha = 0.6
    }
    
    func performFirstSearch() {
        // Add our own gesture recognizer to handle taps on our custom map features.
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onMapTap(recognizer:))))
        
        print("first search starting...")
        let categories: [FilterCategory] = [] //= [FilterCategory.Food_Beverage, FilterCategory.Shopping_Retail,
                          //FilterCategory.Arts_Entertainment, FilterCategory.Travel_Transportation,
                          //FilterCategory.Fitness_Recreation]
        
        if AccessToken.current == nil {
            print("no logged in user, trying anonymous graph request")
        }
        print(currentCoordinates)
        PlaceSearch().fetchPlaces(with: categories, location: currentCoordinates, success: { (places: [Place]?) in
            if let places = places {
                print("got places, adding")
                self.placeArray = places
                if self.moreControl.selectedSegmentIndex == 1 {
                    self.numResults = 20
                }
                let end = min(self.placeArray!.count, self.numResults)
                self.addPlaces(places: Array(places[..<end]))
            }
        }) { (error: Error) in
            print("Error fetching places with updated filters. Error: \(error)")
        }
    }
    
    // MARK: - Manage Places and AR Pins
    func addPlaces( places: [Place] ) {
        print( "* places.count=\(places.count)")
        
        for index in 0..<places.count {
            let place = places[index]
            
            let location = CLLocation(coordinate: place.coordinate, altitude: 30, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
            // set user's current location to get the distance
            // place.userLocation = currentLocation
            // guard let distance = place.distance else {
            //    return
            //}
            // let distanceStr = "\(distance) meters"
            
            let annotation2D = Annotation(location: location, nodeImage: #imageLiteral(resourceName: "pin"), calloutImage: nil, place: place)
            mapView.addAnnotation(annotation2D)
            self.annotationManager.addAnnotation(annotation: annotation2D)
            guard let placename = annotation2D.place?.name else {
                return
            }
            print(placename)
        }
    
    }
    
    func refreshPins(withList list: List) {
        removeExistingPins()
        
        let placeIDs = list.placeIDs
        PlaceSearch().fetchPlaces(with: placeIDs, success: { (places: [Place]) in
            self.placeArray = places
            self.addPlaces(places: places)
        }) { (error: Error) in
            print("error fetching places")
        }
    }
    
    func refreshPins(withCategories categories: [FilterCategory]) {
        removeExistingPins()
        
        // Add new pins
        PlaceSearch().fetchPlaces(with: categories, location: currentCoordinates, success: { (places: [Place]?) in
            if let places = places {
                self.placeArray = places
                let end = min(self.placeArray!.count, self.numResults)
                self.addPlaces(places: Array(places[..<end]))
            }
        }) { (error: Error) in
            print("Error fetching places with updated filters. Error: \(error)")
        }
    }
    
    func changeNumPins() {
        removeExistingPins()
        
        let end = min(placeArray!.count, numResults)
        print("placing \(end) pins")
        self.addPlaces(places: Array(placeArray![..<end]))
    }
    
    func removeExistingPins() {
        // Remove existing pins from 3D AR view
        self.annotationManager.removeAllAnnotations()
        
        // Remove pins from 2D map
        if let existingAnnotations = mapView.annotations {
            mapView.removeAnnotations(existingAnnotations)
        }
    }
    
    // MARK: - Directions
    
    // Query the directions endpoint with waypoints that are the current center location of the map
    // as the start and the passed in location as the end
    func queryDirections(with endLocation: CLLocation) {
        let currentLocation = CLLocation(latitude: self.mapView.centerCoordinate.latitude, longitude: self.mapView.centerCoordinate.longitude)
        annotationManager.originLocation = currentLocation
        
        let waypoints = [
            Waypoint(coordinate: CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude), name: "start"),
            Waypoint(coordinate: CLLocationCoordinate2D(latitude: endLocation.coordinate.latitude, longitude: endLocation.coordinate.longitude), name: "end"),
            ]
        
        // Ask for walking directions
        let options = RouteOptions(waypoints: waypoints, profileIdentifier: .walking)
        options.includesSteps = true
        
        var annotationsToAdd = [Annotation]()
        
        // Initiate the query
        let _ = directions.calculate(options) { (waypoints, routes, error) in
            guard error == nil else {
                print("Error calculating directions: \(error!)")
                return
            }
            
            // If a route is returned:
            if let route = routes?.first, let leg = route.legs.first {
                var polyline = [CLLocationCoordinate2D]()
                
                // Add an AR node and map view annotation for every defined "step" in the route
                for step in leg.steps {
                    let coordinate = step.coordinates!.first!
                    polyline.append(coordinate)
                    let stepLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    
                    // Update feature collection for map view
                    self.updateShapeCollectionFeature(&self.waypointShapeCollectionFeature, with: stepLocation, typeKey: "waypoint-type", typeAttribute: "big")
                    
                    // Add an AR node
                    let annotation = Annotation(location: stepLocation, calloutImage: self.calloutImage(for: step.description), place: nil)
                    annotationsToAdd.append(annotation)
                }
                
                let metersPerNode: CLLocationDistance = 5
                let turfPolyline = Polyline(polyline)
                
                // Walk the route line and add a small AR node and map view annotation every metersPerNode
                for i in stride(from: metersPerNode, to: turfPolyline.distance() - metersPerNode, by: metersPerNode) {
                    // Use Turf to find the coordinate of each incremented distance along the polyline
                    if let nextCoordinate = turfPolyline.coordinateFromStart(distance: i) {
                        let interpolatedStepLocation = CLLocation(latitude: nextCoordinate.latitude, longitude: nextCoordinate.longitude)
                        
                        // Update feature collection for map view
                        self.updateShapeCollectionFeature(&self.waypointShapeCollectionFeature, with: interpolatedStepLocation, typeKey: "waypoint-type", typeAttribute: "small")
                        
                        // Add an AR node
                        let annotation = Annotation(location: interpolatedStepLocation, calloutImage: nil, place: nil)
                        annotationsToAdd.append(annotation)
                    }
                }
                
                // Update the source used for route line visualization with the latest waypoint shape collection
                self.updateSource(identifer: "annotationSource", shape: self.waypointShapeCollectionFeature)
                
                // Update the annotation manager with the latest AR annotations
                self.annotationManager.addAnnotations(annotations: annotationsToAdd)
                
                self.mapView.userTrackingMode = .followWithHeading
            }
        }
        
        // Put the map view into a "follow with course" tracking mode
        mapView.userTrackingMode = .followWithCourse
    }
    
    private func calloutImage(for stepDescription: String) -> UIImage? {
        
        let lowerCasedDescription = stepDescription.lowercased()
        var image: UIImage?
        
        if lowerCasedDescription.contains("arrived") {
            image = UIImage(named: "arrived")
        } else if lowerCasedDescription.contains("left") {
            image = UIImage(named: "turnleft")
        } else if lowerCasedDescription.contains("right") {
            image = UIImage(named: "turnright")
        } else if lowerCasedDescription.contains("head") {
            image = UIImage(named: "straightahead")
        }
        
        return image
    }
    
    // MARK: - Actions
    @objc func onMapTap(recognizer: UITapGestureRecognizer) {
        print("tapped")
        let location = recognizer.location(in: sceneView)
        
        let hitResults = sceneView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            print("hit")
            let result = hitResults[0]
            let node = result.node
            print(node)
            showDetail(from: node)
        }
    }
    
    func showDetail(from node: SCNNode) {
        guard let annotation = annotationManager.annotationsByNode[node] else {
            guard let parentNode = node.parent else {
                print("no parent")
                return
            }
            print("trying parent")
            return showDetail(from: parentNode)
        }
        print("hit annotation")
        guard let tappedPlace = annotation.place else {
            print("no place")
            return
        }
        print("found place")
        showDetailVC(forPlace: tappedPlace)
    }
    
    @IBAction func onMapButton(_ sender: Any) {
        slideMap()
    }
    
    func slideMap() {
        // Slide map up/down from bottom
        let distance = self.mapBottom?.constant == 0 ? mapView.frame.height : 0
        self.mapBottom?.constant = distance
        self.mapTop?.constant = distance
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func onFilterButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Filter", bundle: nil)
        let filterNVC = storyboard.instantiateViewController(withIdentifier: "FilterNavigationControllerID") as! UINavigationController
        
        let filterVC = filterNVC.topViewController as! FilterViewController
        filterVC.delegate = self
        
        filterVC.coordinates = currentCoordinates
        
        present(filterNVC, animated: true, completion: nil)
    }
    
    @IBAction func onMoreResults(_ sender: Any) {
        switch moreControl.selectedSegmentIndex {
        case 0:
            numResults = 10
            changeNumPins()
        case 1:
            numResults = 20
            changeNumPins()
        default:
            break
        }
    }
    

    // MARK: - Navigation

    func showDetailVC(forPlace place: Place) {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        let detailNVC = storyboard.instantiateViewController(withIdentifier: "DetailNavigationController") as! UINavigationController
        
        let detailVC = detailNVC.topViewController as! PlaceDetailTableViewController
        detailVC.place = place
        detailVC.delegate = self
        
        present(detailNVC, animated: true, completion: nil)
    }

}

// MARK: - AnnotationManagerDelegate

extension AugmentedViewController: AnnotationManagerDelegate {
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print("camera did change tracking state: \(camera.trackingState)")
        
        switch camera.trackingState {
        case .normal:
            print("Ready!")
        default:
            print("Move the camera")
        }
    }
    
    func node(for annotation: Annotation) -> SCNNode? {
        
        if let nodeImage = annotation.nodeImage {
            // node image supplied (place)
            return createPinNode(with: nodeImage)
        } else if annotation.calloutImage != nil { // && annotation.nodeImage == nil {
            // only callout image supplied (waypoints of directions), make the flashing ball underneath
            let firstColor = UIColor(red: 0.0, green: 99/255.0, blue: 175/255.0, alpha: 1.0)
            return createSphereNode(with: 0.5, firstColor: firstColor, secondColor: UIColor.green)
        } else {
            // no special node or callout image supplied (Pac-Man breadcrumbs for directions)
            // Comment `createLightBulbNode` and add `return nil` to use the default node
            // return createLightBulbNode()
            return nil
        }
    }
    
    // MARK: - Utility methods for AnnotationManagerDelegate
    
    func createSphereNode(with radius: CGFloat, firstColor: UIColor, secondColor: UIColor) -> SCNNode {
        let geometry = SCNSphere(radius: radius)
        geometry.firstMaterial?.diffuse.contents = firstColor
        
        let sphereNode = SCNNode(geometry: geometry)
        sphereNode.animateInterpolatedColor(from: firstColor, to: secondColor, duration: 1)
        
        return sphereNode
    }
    
    func createPinNode(with image: UIImage) -> SCNNode {
            var width: CGFloat = 0.0
            var height: CGFloat = 0.0
            
            if image.size.width >= image.size.height {
                width = 5.0 * (image.size.width / image.size.height)
                height = 5.0
            } else {
                width = 5.0
                height = 5.0 * (image.size.height / image.size.width)
            }
            
            let calloutGeometry = SCNPlane(width: width, height: height)
            calloutGeometry.firstMaterial?.diffuse.contents = image
            
            let pinNode = SCNNode(geometry: calloutGeometry)
            
            let constraint = SCNBillboardConstraint()
            constraint.freeAxes = [.Y]
            pinNode.constraints = [constraint]
            
            return pinNode
    }
    
    func collada2SCNNode(filepath:String) -> SCNNode {
        let node = SCNNode()
        let scene = SCNScene(named: filepath, inDirectory: nil, options: [SCNSceneSource.LoadingOption.animationImportPolicy: SCNSceneSource.AnimationImportPolicy.doNotPlay])
        guard let nodeArray = scene?.rootNode.childNodes else {
            return node
        }
        for childNode in nodeArray {
            node.addChildNode(childNode as SCNNode)
        }
        return node
    }
    
}

// MARK: - MGLMapViewDelegate

extension AugmentedViewController: MGLMapViewDelegate {
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        annotationManager.originLocation = currentLocation
        performFirstSearch()
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        // Set up Mapbox iOS Maps SDK "runtime styling" source and style layers to style the directions route line
        waypointShapeCollectionFeature = MGLShapeCollectionFeature()
        let annotationSource = MGLShapeSource(identifier: "annotationSource", shape: waypointShapeCollectionFeature, options: nil)
        mapView.style?.addSource(annotationSource)

        let circleStyleLayer = MGLCircleStyleLayer(identifier: "circleStyleLayer", source: annotationSource)

        let color = UIColor(red: 147/255.0, green: 230/255.0, blue: 249/255.0, alpha: 1.0)
        let colorStops = ["small": MGLStyleValue<UIColor>(rawValue: color.withAlphaComponent(0.75)),
                          "big": MGLStyleValue<UIColor>(rawValue: color)]
        circleStyleLayer.circleColor = MGLStyleValue(
            interpolationMode: .categorical,
            sourceStops: colorStops,
            attributeName: "waypoint-type",
            options: nil
        )
        let sizeStops = ["small": MGLStyleValue<NSNumber>(rawValue: 2),
                         "big": MGLStyleValue<NSNumber>(rawValue: 4)]
        circleStyleLayer.circleRadius = MGLStyleValue(
            interpolationMode: .categorical,
            sourceStops: sizeStops,
            attributeName: "waypoint-type",
            options: nil
        )
        mapView.style?.addLayer(circleStyleLayer)
    }
    
    // Use the default marker.
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        return nil
    }
    
    internal func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, leftCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        guard let augmentedAnnotation = annotation as? Annotation, let place = augmentedAnnotation.place else {
            return UIView()
        }
        let detailButton = DetailButton(type: .detailDisclosure)
        detailButton.params["place"] = place
        detailButton.tag = 1

        return detailButton
    }
    
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        guard let augmentedAnnotation = annotation as? Annotation, let place = augmentedAnnotation.place else {
            return UIView()
        }
        let directionsButton = DirectionsButton(type: .detailDisclosure)
        directionsButton.params["place"] = place
        directionsButton.tag = 2
        
        return directionsButton
    }
    
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        guard let augmentedAnnotation = annotation as? Annotation, let place = augmentedAnnotation.place else {
            return
        }
        showDetailVC(forPlace: place)
    }
    
    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        switch control.tag {
        case 1:
            // Left accessory tapped
            let button = control as! DetailButton
            guard let place = button.params["place"] as? Place else {
                return
            }
            showDetailVC(forPlace: place)
        case 2:
            // Right accessory tapped
            let button = control as! DirectionsButton
            guard let place = button.params["place"] as? Place else {
                return
            }
            getDirections(for: place)
        default:
            return
        }
    }
    
    // MARK: - Utility methods for MGLMapViewDelegate
    
    private func updateSource(identifer: String, shape: MGLShape?) {
        guard let shape = shape else {
            return
        }
        
        if let source = mapView.style?.source(withIdentifier: identifer) as? MGLShapeSource {
            source.shape = shape
        }
    }
    
    private func updateShapeCollectionFeature(_ feature: inout MGLShapeCollectionFeature?, with location: CLLocation, typeKey: String?, typeAttribute: String?) {
        if let shapeCollectionFeature = feature {
            let annotation = MGLPointFeature()
            if let key = typeKey, let value = typeAttribute {
                annotation.attributes = [key: value]
            }
            annotation.coordinate = location.coordinate
            let newFeatures = [annotation].map { $0 as MGLShape }
            let existingFeatures: [MGLShape] = shapeCollectionFeature.shapes
            let allFeatures = newFeatures + existingFeatures
            feature = MGLShapeCollectionFeature(shapes: allFeatures)
        }
    }
    
    private func resetShapeCollectionFeature(_ feature: inout MGLShapeCollectionFeature?) {
        if feature != nil {
            feature = MGLShapeCollectionFeature(shapes: [])
        }
    }
    
}

// MARK: - PlaceDetail Delegate
extension AugmentedViewController: PlaceDetailTableViewControllerDelegate {
    func getDirections(for place: Place) {
        if isMapHidden() {
            slideMap()
        }
        queryDirections(with: place.location)
    }
}

// MARK: - FilterViewControllerDelegate
extension AugmentedViewController: FilterViewControllerDelegate {
    func filterViewController(_filterViewController: FilterViewController, didSelectCategories categories: [FilterCategory]) {
        refreshPins(withCategories: categories)
    }
    
    func filterViewController(_filterViewController: FilterViewController, didSelectList list: List) {
        refreshPins(withList : list)
    }
}

// MARK: - Appearance Extensions

extension SCNNode {
    
    func animateInterpolatedColor(from oldColor: UIColor, to newColor: UIColor, duration: Double) {
        let act0 = SCNAction.customAction(duration: duration, action: { (node, elapsedTime) in
            let percentage = elapsedTime / CGFloat(duration)
            self.geometry?.firstMaterial?.diffuse.contents = newColor.interpolatedColor(to: oldColor, percentage: percentage)
        })
        let act1 = SCNAction.customAction(duration: duration, action: { (node, elapsedTime) in
            let percentage = elapsedTime / CGFloat(duration)
            self.geometry?.firstMaterial?.diffuse.contents = oldColor.interpolatedColor(to: newColor, percentage: percentage)
        })
        
        let act = SCNAction.repeatForever(SCNAction.sequence([act0, act1]))
        self.runAction(act)
    }
    
}

extension UIColor {
    
    // https://stackoverflow.com/questions/40472524/how-to-add-animations-to-change-sncnodes-color-scenekit
    func interpolatedColor(to: UIColor, percentage: CGFloat) -> UIColor {
        let fromComponents = self.cgColor.components!
        let toComponents = to.cgColor.components!
        let color = UIColor(red: fromComponents[0] + (toComponents[0] - fromComponents[0]) * percentage,
                            green: fromComponents[1] + (toComponents[1] - fromComponents[1]) * percentage,
                            blue: fromComponents[2] + (toComponents[2] - fromComponents[2]) * percentage,
                            alpha: fromComponents[3] + (toComponents[3] - fromComponents[3]) * percentage)
        return color
    }
    
}

