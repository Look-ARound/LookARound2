//
//  Place.swift
//  LookARound
//
//  Created by Angela Yu on 10/12/17.
//  Copyright © 2017 LookARound. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import Mapbox

class Place: NSObject {
    var id: String!
    var name: String
    var latitude: Double
    var longitude: Double
    var address: String?
    var about: String?
    var category: String?
    var thumbnail: String? = ""
    var picture: String? = ""
    var contextCount: Int?
    var context: String?
    var checkins: Int?
    var link: String?
    var distance: CLLocationDistance?
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    var location: CLLocation {
        get {
            return CLLocation(latitude: latitude, longitude: longitude)
        }
    }
    
    var userLocation: CLLocation? {
        didSet {
            //if let userLocation = userLocation {
                distance = location.distance(from: userLocation!)
           // }
        }
    }
    
    init?(json: JSON) {
        // TODO Guard against json not having required values
        id = json["id"].stringValue
        name = json["name"].stringValue
        latitude = json["location"]["latitude"].doubleValue
        longitude = json["location"]["longitude"].doubleValue
        address = json["location"]["street"].stringValue
        about = json["about"].stringValue
        thumbnail = json["picture"]["data"]["url"].stringValue
        picture = json["cover"]["source"].stringValue
        context = json["context"]["friends_who_like"]["summary"]["social_sentence"].stringValue
        contextCount = json["context"]["friends_who_like"]["summary"]["total_count"].intValue
        checkins = json["checkins"].intValue
        category = json["category_list"][0]["name"].stringValue
        link = json["link"].stringValue
    }
    
    // MANUAL INIT for debugging and testing
    init(id: String, name: String, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
