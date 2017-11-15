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
import HDAugmentedReality

// Used for AR Callouts
public class HDAnnotation: ARAnnotation {
    // MARK: - Inherited Properties
    // title: String
    // location: CLLocation

    // MARK: - Stored Properties
    public var leftImage: UIImage?
    public var anchor: LookAnchor?
    var place: Place?

    public var coordinate: CLLocationCoordinate2D
    public var subtitle: String?

    // Custom properties that we will use to customize the annotation's image.
    var image: UIImage?
    var reuseIdentifier: String?

    init?(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.subtitle = subtitle
        let loc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        super.init(identifier: subtitle, title: title, location: loc)
    }

    init?(location: CLLocation, leftImage: UIImage?, place: Place?) {
        var placeTitle = ""
        self.coordinate = location.coordinate
        if let myPlace = place {
            self.place = myPlace
            placeTitle = myPlace.name
            if let checkinCount = myPlace.checkins {
                if let friendCount = myPlace.contextCount {
                    switch friendCount {
                    case 1:
                        self.subtitle = "\(friendCount) friend likes this"
                    case _ where friendCount > 1:
                        self.subtitle = "\(friendCount) friends like this"
                    case 0:
                        self.subtitle = "\(checkinCount) checkins here"
                    default:
                        self.subtitle = nil
                    }
                }
            }
        }
        if let leftImage = leftImage {
            self.leftImage = leftImage
        }
        super.init(identifier: subtitle, title: placeTitle, location: location)
    }
}

// MARK: - Annotation2D
// Used for 2D map annotations & callouts and for AR directions
public class LAAnnotation2D: NSObject, MGLAnnotation {
    
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
            if let checkinCount = myPlace.checkins {
                if let friendCount = myPlace.contextCount {
                    switch friendCount {
                    case 1:
                        self.subtitle = "\(friendCount) friend likes this"
                    case _ where friendCount > 1:
                        self.subtitle = "\(friendCount) friends like this"
                    case 0:
                        self.subtitle = "\(checkinCount) checkins here"
                    default:
                        self.subtitle = nil
                    }
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
            if let checkinCount = myPlace.checkins {
                if let friendCount = myPlace.contextCount {
                    switch friendCount {
                    case 1:
                        self.subtitle = "\(friendCount) friend likes this"
                    case _ where friendCount > 1:
                        self.subtitle = "\(friendCount) friends like this"
                    case 0:
                        self.subtitle = "\(checkinCount) checkins here"
                    default:
                        self.subtitle = nil
                    }
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
