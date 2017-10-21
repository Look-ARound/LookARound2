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

class AugmentedViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var controlsContainerView: UIView!
    @IBOutlet weak var cameraInfoStateLabel: UILabel!
    @IBOutlet weak var mapView: MGLMapView!
    var mapTop: NSLayoutConstraint!
    var mapBottom: NSLayoutConstraint!
    
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    
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
            return coreLocation
        }
    }
    
    var currentCoordinates: CLLocationCoordinate2D {
        get {
            return currentLocation.coordinate
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure and style control and map views
        styleControlViewContainer()
        configureMapboxMapView()
        
        // SceneKit
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.scene = SCNScene()
        
        // Create an AR annotation manager and give it a reference to the AR scene view
        annotationManager = AnnotationManager(sceneView: sceneView)
        annotationManager.delegate = self
        
        // Set up the UI elements as per the app theme
        prepButtonsWithARTheme(buttons: [filterButton, mapButton])
        
        performFirstSearch()
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
    
    // MARK: - AR scene setup
    func performFirstSearch() {
        print("first search starting...")
        let categories = [FilterCategory.Food_Beverage, FilterCategory.Shopping_Retail,
                          FilterCategory.Arts_Entertainment, FilterCategory.Travel_Transportation,
                          FilterCategory.Fitness_Recreation]
        
        guard AccessToken.current != nil else {
            print("no logged in user")
            return
        }
        PlaceSearch().fetchPlaces(with: categories, location: currentCoordinates, success: { [weak self] (places: [Place]?) in
            if let places = places {
                print("got places, adding")
                self?.addPlaces(places: places)
            }
        }) { (error: Error) in
            print("Error fetching places with updated filters. Error: \(error)")
        }
    }
    
    func addPlaces( places: [Place] ) {
        print( "* places.count=\(places.count)")
        for index in 0..<places.count {
            let place = places[index]
            
            let name = place.name
            let coordinate = place.coordinate
            // set user's current location to get the distance
            place.userLocation = currentLocation
            guard let distance = place.distance else {
                return
            }
            let distanceStr = "\(distance) meters"
            
            let annotation2D = MGLPointAnnotation()
            annotation2D.coordinate = coordinate
            annotation2D.title = name
            annotation2D.subtitle = distanceStr
            mapView.addAnnotation(annotation2D)
            
            let annotation = Annotation(location: place.location, calloutImage: nil, place: place)
            self.annotationManager.addAnnotation(annotation: annotation)
        }
    }
    
    func refreshPins(withCategories categories: [FilterCategory]) {
        
        removeExistingPins()
        
        // Add new pins
        PlaceSearch().fetchPlaces(with: categories, location: currentCoordinates, success: { [weak self] (places: [Place]?) in
            if let places = places {
                print("got places, adding")
                self?.addPlaces(places: places)
            }
        }) { (error: Error) in
            print("Error fetching places with updated filters. Error: \(error)")
        }
    }
    
    func removeExistingPins() {
        // Remove existing pins from 3D AR view
        self.annotationManager.removeAllAnnotations()
        
        // Remove pins from 2D map
        if let existingAnnotations = mapView.annotations {
            mapView.removeAnnotations(existingAnnotations)
        }
    }
    
    // MARK: - 2D Map setup
    func initMap()
    {
        mapView.alpha = 0.9
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapTop = mapView.topAnchor.constraint(equalTo: view.centerYAnchor)
        mapTop.isActive = true
        mapBottom = mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        mapBottom.isActive = true
        
        // Move mapView offscreen (below view)
        self.view.layoutIfNeeded() // Do this, otherwise frame.height will be incorrect
        mapTop.constant = mapView.frame.height
        mapBottom.constant = mapView.frame.height
    }
    
    // MARK: - Actions
    
    // Handle a long press on the Mapbox map view
    // Adds an annotation where the long press happened and routes directions to that place from current locatin
    @IBAction func didLongPress(_ recognizer: UILongPressGestureRecognizer) {

        // Find the geographic coordinate of the point pressed in the map view
        let point = recognizer.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        // Remove any existing annotations on the map view
        if let existingAnnotations = mapView.annotations {
            mapView.removeAnnotations(existingAnnotations)
        }
        
        // Add an annotation to the map view for the pressed point
        let annotation = MGLPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        // When the gesture ends use the annotation location to initiate a query to the Mapbox Directions API
        if recognizer.state == .ended {
            
            // remove any previously rendered route
            annotationManager.removeAllAnnotations()
            resetShapeCollectionFeature(&waypointShapeCollectionFeature)
            self.updateSource(identifer: "annotationSource", shape: self.waypointShapeCollectionFeature)
            
            // Create a CLLocation instance to represent the end location for the directions query
            let annotationLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            queryDirections(with: annotationLocation)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let result = sceneView.hitTest(touch.location(in: sceneView), options: [SCNHitTestOption.firstFoundOnly : true]).first
        if let node = result?.node, let annotation = annotationManager.annotationsByNode[node],
            let tappedPlace = annotation.place {
            showDetailVC(forPlace: tappedPlace)
        }
    }
    
    @IBAction func onMapButton(_ sender: Any) {
        slideMap()
    }
    
    func isMapHidden() -> Bool {
        return !(self.mapBottom?.constant == 0)
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
                    let annotation = Annotation(location: stepLocation, calloutImage: self.calloutImage(for: step.description))
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
                        let annotation = Annotation(location: interpolatedStepLocation, calloutImage: nil)
                        annotationsToAdd.append(annotation)
                    }
                }
                
                // Update the source used for route line visualization with the latest waypoint shape collection
                self.updateSource(identifer: "annotationSource", shape: self.waypointShapeCollectionFeature)
                
                // Update the annotation manager with the latest AR annotations
                self.annotationManager.addAnnotations(annotations: annotationsToAdd)
            }
        }
        
        // Put the map view into a "follow with course" tracking mode
        mapView.userTrackingMode = .followWithCourse
    }
    
    // MARK: - Utility methods
    
    private func startSession() {
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        if automaticallyFindTrueNorth {
            configuration.worldAlignment = .gravityAndHeading
        } else {
            configuration.worldAlignment = .gravity
        }
        
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func prepButtonsWithARTheme(buttons : [UIButton]) {
        for button in buttons {
            button.setTitleColor(UIColor.LABrand.primary, for: .normal)
            button.layer.cornerRadius = button.frame.size.height * 0.5
            button.clipsToBounds = true
            button.alpha = 0.6
        }
    }
    
    private func styleControlViewContainer() {
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = controlsContainerView.bounds
        blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        controlsContainerView.insertSubview(blurView, belowSubview: mapView)
    }
    
    private func configureMapboxMapView() {
        mapView.delegate = self
        mapView.styleURL = URL(string: "mapbox://styles/mapbox/cj3kbeqzo00022smj7akz3o1e") // "Moonlight" style
        mapView.userTrackingMode = .followWithHeading
        mapView.layer.cornerRadius = 10
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
            cameraInfoStateLabel.text = "Ready!"
            UIView.animate(withDuration: 1, delay: 1, options: [], animations: {
                self.cameraInfoStateLabel.alpha = 0
            }, completion: nil)
        default:
            cameraInfoStateLabel.alpha = 1
            cameraInfoStateLabel.text = "Move the camera"
        }
    }
    
    func node(for annotation: Annotation) -> SCNNode? {
        
        if annotation.calloutImage == nil {
            // Comment `createLightBulbNode` and add `return nil` to use the default node
            return createLightBulbNode()
        } else {
            let firstColor = UIColor(red: 0.0, green: 99/255.0, blue: 175/255.0, alpha: 1.0)
            return createSphereNode(with: 0.5, firstColor: firstColor, secondColor: UIColor.green)
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
    
    func createLightBulbNode() -> SCNNode {
        let lightBulbNode = collada2SCNNode(filepath: "art.scnassets/light-bulb.dae")
        lightBulbNode.scale = SCNVector3Make(0.25, 0.25, 0.25)
        return lightBulbNode
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
    
    func generateFeature(centerCoordinate: CLLocationCoordinate2D) -> MGLPointFeature {
        let feature = MGLPointFeature()
        feature.coordinate = centerCoordinate
        return feature
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

extension AugmentedViewController: PlaceDetailTableViewControllerDelegate {
    func getDirections(destLat: Double, destLong: Double) {
        if isMapHidden() {
            slideMap()
        }
        //mapView.getDirections( source: (LocationService.shared.getCurrentLocation()?.coordinate)!, dest: CLLocationCoordinate2D(latitude: destLat, longitude: destLong))
    }
}

// MARK: - FilterViewControllerDelegate
extension AugmentedViewController: FilterViewControllerDelegate {
    func filterViewController(_filterViewController: FilterViewController, didSelectCategories categories: [FilterCategory]) {
        
        refreshPins(withCategories: categories)
    }
}

// MARK: - Extensions

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

