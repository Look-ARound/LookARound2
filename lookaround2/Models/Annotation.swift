//
//  AugmentedViewController.swift
//  lookaround2
//
//  Created by Angela Yu on 10/20/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//  Forked from MapBox + ARKit by MapBox at https://github.com/mapbox/mapbox-arkit-ios
//

import UIKit
import CoreLocation
import Mapbox

public class Annotation: NSObject, MGLAnnotation {
    
    public var location: CLLocation
    public var nodeImage: UIImage?
    public var calloutImage: UIImage?
    public var anchor: LookAnchor?
    var place: Place?
    
    public var coordinate: CLLocationCoordinate2D
    public var title: String?
    public var subtitle: String?
    
    // Custom properties that we will use to customize the annotation's image.
    var image: UIImage?
    var reuseIdentifier: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    init(location: CLLocation, calloutImage: UIImage?, place: Place?) {
        self.location = location
        self.coordinate = location.coordinate
        if let myPlace = place {
            self.place = myPlace
            self.title = myPlace.name
            if let friendCount = myPlace.contextCount {
                switch friendCount {
                case 1:
                    self.subtitle = "\(friendCount) friend likes this"
                case _ where friendCount > 1:
                    self.subtitle = "\(friendCount) friends like this"
                default:
                    self.subtitle = nil
                }
            }
        }
        if let image = calloutImage {
            self.calloutImage = image
        }
    }
    
    init(location: CLLocation, nodeImage: UIImage?, calloutImage: UIImage?, place: Place?) {
        self.location = location
        self.coordinate = location.coordinate
        if let myPlace = place {
            self.place = myPlace
            self.title = myPlace.name
            if let friendCount = myPlace.contextCount {
                if friendCount > 0 {
                    self.subtitle = "\(friendCount) friends like this"
                }
            }
        }
        if let nodeImage = nodeImage {
            self.nodeImage = nodeImage
        }
        if let calloutImage = calloutImage {
            self.calloutImage = calloutImage
        }
    }
    
}
