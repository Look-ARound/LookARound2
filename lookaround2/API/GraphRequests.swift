//
//  PlaceRequest.swift
//  LookARound
//
//  Created by Angela Yu on 10/12/17.
//  Copyright © 2017 LookARound. All rights reserved.
//

import Foundation
import FacebookCore
import CoreLocation
import SwiftyJSON

enum sortMethod: Int {
    case magic = 0
    case friends = 1
    case checkins = 2
}

// MARK: - Place Search methods for Place Search Graph request
struct PlaceSearch {
    static var autoGenLikes: Bool = false // For debugging/demo
    
    fileprivate func presetRequest() -> PlaceSearchRequest {
        var request = PlaceSearchRequest()
        
        if let token = AccessToken.current {
            request.accessToken = token
            request.parameters?["fields"] = "id, name, about, location, category_list, checkins, picture, cover, single_line_address, context"
        } else {
            print("search with logged out user")
            request.accessToken = nil
            request.parameters?["access_token"] = Bundle.main.object(forInfoDictionaryKey: "FacebookAppSecret")
            request.parameters?["fields"] = "id, name, about, location, category_list, checkins, picture, cover, single_line_address"
        }
        
        request.parameters?["limit"] = 30
        
        return request
    }
    
    // When no location detected, use default of Facebook Building 20
    func fetchPlaces(with categories:[FilterCategory]?, success: @escaping ([Place]?)->(), failure: @escaping (Error)->()) -> Void {
        
        let location = CLLocationCoordinate2D(latitude: 37.4816734, longitude: -122.1556204)
        fetchPlaces(with: categories, location: location, success: { places in
            success(places)
        }) { error in
            failure(error)
        }
    }
    
    // When no distance radius specified, use default of 1000 meters from center
    func fetchPlaces(with categories:[FilterCategory]?, location: CLLocationCoordinate2D,  success: @escaping ([Place]?)->(), failure: @escaping (Error)->()) -> Void {
        let distance = 1000
        fetchPlaces(with: categories, location: location, distance: distance, success: { places in
            success(places)
        }) { error in
            failure(error)
        }
    }
    
    // Fully featured PlaceSearch.fetchPlaces
    func fetchPlaces(with categories:[FilterCategory]?, location: CLLocationCoordinate2D, distance: Int,
                     success: @escaping ([Place]?)->(), failure: @escaping (Error)->()) -> Void {
        
        var request = presetRequest()
        
        if let categories = categories {
            request.graphPath = graphPathString(categories: categories)
        } else {
            request.graphPath = "/search?type=place"
        }
        
        request.parameters?["center"] = "\(location.latitude), \(location.longitude)"
        request.parameters?["distance"] = distance
        
        let searchConnection = GraphRequestConnection()
        searchConnection.add(request) { (response, result: GraphRequestResult) in
            switch result {
            case .success(let response):
                // For debugging/demo
                if PlaceSearch.autoGenLikes == true {
                    for index in 0..<response.places.count {
                        let val = arc4random_uniform(5)+1
                        response.places[index].contextCount = Int(val)
                    }
                }
                success(response.places)
            case .failed(let error):
                failure(error)
            }
        }
        searchConnection.start()
    }
    
    func fetchPlaces(with searchTerm:String, coordinates: CLLocationCoordinate2D, success: @escaping ([Place]?)->(), failure: @escaping (Error)->()) -> Void {
        let placeSearchConnection = GraphRequestConnection()
        
        var placeSearchRequest = presetRequest()
        print(searchTerm)
        placeSearchRequest.graphPath = "/search?type=place&q=\(searchTerm)"
        placeSearchRequest.parameters?["center"] = "\(coordinates.latitude), \(coordinates.longitude)"
        placeSearchRequest.parameters?["distance"] = 1000
        placeSearchRequest.parameters?["limit"] = 10
        print(placeSearchRequest.parameters)
        placeSearchConnection.add(placeSearchRequest,
                                  batchEntryName: nil) { (response, result) in
                                    switch result {
                                    case .success(let response):
                                        success(response.places)
                                    case .failed(let error):
                                        print("Failed to fetch place with term: \(searchTerm)")
                                        failure(error)
                                    }
        }
        placeSearchConnection.start()
    }
    
    fileprivate func presetIDRequest() -> PlaceIDSearchRequest {
        var request = PlaceIDSearchRequest()
        
        if let token = AccessToken.current {
            request.accessToken = token
            request.parameters?["fields"] = "id, name, about, location, category_list, checkins, picture, cover, single_line_address, context"
        } else {
            print("search with logged out user")
            request.accessToken = nil
            request.parameters?["access_token"] = Bundle.main.object(forInfoDictionaryKey: "FacebookAppSecret")
            request.parameters?["fields"] = "id, name, about, location, category_list, checkins, picture, cover, single_line_address"
        }
        
        return request
    }
    
    func fetchPlaces(with placeIDs:[String], success: @escaping ([Place])->(), failure: @escaping (Error)->()) -> Void {
        var places: [Place] = []
        // Add multiple requests to the same connection
        let placeIDSearchConnection = GraphRequestConnection()
        
        for placeID in placeIDs {
            var placeIDRequest = presetIDRequest()
            placeIDRequest.graphPath = "/\(placeID)"
            placeIDSearchConnection.add(placeIDRequest, batchParameters: nil, completion: { (response, result: GraphRequestResult) in
                switch result {
                case .success(let response):
                    if let place = response.place {
                        places.append(place)
                        success(places)
                    }
                case .failed(let error):
                    print("Failed to fetch place with id /(placeID)")
                    failure(error)
                }
            })
        }
        placeIDSearchConnection.start()
    }
}

// Passing categories as an array in Parameters doesn't seem to be working so we need to construct a query string.
private func graphPathString(categories : [FilterCategory]) -> String {
    var categoriesStr = ""
    for category in categories {
        categoriesStr += "%22\(FilterCategorySearchString(category: category))%22,"
    }
    
    let graphPath = "/search?type=place&categories=[" + categoriesStr + "]"
    
    return graphPath
}

func sortPlaces(places: [Place], by method: sortMethod) -> [Place] {
    switch method {
    case .magic:
        let friendSortFirst = sortPlaces(places: places, by: .friends)
        guard let lastFriendsIndex = friendSortFirst.index(where: { $0.contextCount == 0}) else {
            return friendSortFirst
        }
        let friendSortResult = Array(friendSortFirst[..<lastFriendsIndex])
        let remainderPlaces = Array(friendSortFirst.suffix(from: lastFriendsIndex))
        let checkinSortSecond = sortPlaces(places: remainderPlaces, by: .checkins)
        let resultPlaces = friendSortResult + checkinSortSecond
        return resultPlaces
    case .checkins:
        let sortedPlaces = places.sorted(by: {
            guard let firstCheckins = $0.checkins else {
                return true
            }
            guard let secondCheckins = $1.checkins else {
                return true
            }
            return firstCheckins > secondCheckins
        })
        return sortedPlaces
    case .friends:
        let sortedPlaces = places.sorted(by: {
            guard let firstFriends = $0.contextCount else {
                return false
            }
            guard let secondFriends = $1.contextCount else {
                return false
            }
            return firstFriends > secondFriends
        })
        return sortedPlaces
    }
}

/// Use PlaceSearch().fetchPlaces instead of using this directly.
private struct PlaceSearchRequest: GraphRequestProtocol {
    
    // GraphPath documentation at https://developers.facebook.com/docs/places/web/search
    var graphPath: String = "" // This string will be populated with the graphPathString function which is called by PlaceSearch().fetchPlaces.
    
    // Places available fields documentation at https://developers.facebook.com/docs/places/fields
    var parameters: [String: Any]? = ["fields": "id, name, about, location, category_list, checkins, picture, cover, single_line_address"]
    
    // Access documented at https://developers.facebook.com/docs/places/access-tokens
    // Default access token is the public client token, used for logged-out users
    // var accessToken: AccessToken? = AccessToken.init(authenticationToken: SDKSettings.clientToken!)
    var accessToken: AccessToken?
    var httpMethod: GraphRequestHTTPMethod = .GET
    var apiVersion: GraphAPIVersion = .defaultVersion
    
    typealias Response = PlaceSearchResponse
}

/// Use PlaceSearch().fetchPlaces instead of using this directly.
private struct PlaceIDSearchRequest: GraphRequestProtocol {
    
    // GraphPath documentation at https://developers.facebook.com/docs/places/web/search
    var graphPath: String = "" // This string will be populated with the graphPathString function which is called by PlaceSearch().fetchPlaces.
    
    // Places available fields documentation at https://developers.facebook.com/docs/places/fields
    var parameters: [String: Any]? = ["fields": "id, name, about, location, category_list, checkins, picture, cover, single_line_address"]
    
    // Access documented at https://developers.facebook.com/docs/places/access-tokens
    // Default access token is the public client token, used for logged-out users
    // var accessToken: AccessToken? = AccessToken.init(authenticationToken: SDKSettings.clientToken!)
    var accessToken: AccessToken?
    var httpMethod: GraphRequestHTTPMethod = .GET
    var apiVersion: GraphAPIVersion = .defaultVersion
    
    typealias Response = PlaceIDSearchResponse
}

private struct PlaceSearchResponse: GraphResponseProtocol {
    var places: [Place]
    
    init(rawResponse: Any?) {
        // Decode JSON from rawResponse into other properties here.
        /* Sample API response for Angela Yu searching at Builing 20:
         use JSON viewer to collapse and expand tree here https://codebeautify.org/jsonviewer/cbe6c6f2
         */
        let json = JSON(rawResponse!)
        // print(json)
        var rawPlaces: [Place] = []
        var spots = json["data"].arrayValue
        if spots.count == 0 {
            // When we do a place search based on just the ID (from lists), we get back the data in a different format.
            // In the category search case the root node is 'data', in the ID search case the data is present in the node directly.
            // TODO: make this code easier to understand. Maybe create a new GraphResponseProtocol struct?
            spots = [json]
        }
        
        for spot in spots {
            if let thisPlace = Place(json: spot) {
                rawPlaces.append(thisPlace)
            }
        }
        let sortedPlaces = sortPlaces(places: rawPlaces, by: .magic)
        places = sortedPlaces
    }
}

private struct PlaceIDSearchResponse: GraphResponseProtocol {
    var place: Place?
    
    init(rawResponse: Any?) {
        // Decode JSON from rawResponse into other properties here.

        let json = JSON(rawResponse!)
        if let unwrappedPlace = Place(json: json) {
            place = unwrappedPlace
        } else {
            print("couldn't unwrap place")
        }
    }
}


// MARK: - Profile Graph Request
var LAFBUserIDKey : String = "FBUserIDKey"

class ProfileRequest {
    func fetchCurrentUserID(success: @escaping (String!)->(), failure: @escaping (Error)->()) -> Void {
        if let defaultsUserID = UserDefaults.standard.string(forKey: LAFBUserIDKey) {
            success(defaultsUserID)
        } else {
            // Fetch user profile first, then get the ID
            fetchCurrentUser(success: { (user: User) in
                success(user.id)
            }, failure: { (error: Error) in
                failure(error)
            })
        }
    }
    
    func fetchCurrentUser(success: @escaping (User)->(), failure: @escaping (Error)->()) -> Void {
        let currentUserRequest = MyProfileRequest()
        
        let currentUserConnection = GraphRequestConnection()
        currentUserConnection.add(currentUserRequest) { (response, result: GraphRequestResult) in
            switch result {
            case .success(let response):
                // Save userID in defaults
                UserDefaults.standard.set(response.user.id, forKey: LAFBUserIDKey)
                
                success(response.user)
            case .failed(let error):
                // Remove userID from defaults
                UserDefaults.standard.removeObject(forKey: LAFBUserIDKey)
                
                failure(error)
            }
        }
        currentUserConnection.start()
    }
}

fileprivate struct MyProfileResponse : GraphResponseProtocol {
    var user: User
    
    init(rawResponse: Any?) {
        // Decode JSON from rawResponse into other properties here.
        let json = JSON(rawResponse!)
        print(json)
        let id = json["id"].stringValue
        let name = json["name"].stringValue
        let photoURL = json["picture"]["data"]["url"].stringValue
        
        user = User()
        user.id = id
        user.name = name
        user.profileImageURL = photoURL
        
        print(id)
        print(name)
        print(photoURL)
    }
}

fileprivate struct MyProfileRequest: GraphRequestProtocol {
    var graphPath = "/me"
    var parameters: [String : Any]? = ["fields": "id, name, picture{url}"]
    var accessToken = AccessToken.current
    var httpMethod: GraphRequestHTTPMethod = .GET
    var apiVersion: GraphAPIVersion = .defaultVersion
    typealias Response = MyProfileResponse
}

