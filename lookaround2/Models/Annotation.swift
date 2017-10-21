import UIKit
import CoreLocation

public class Annotation: NSObject {
    
    public var location: CLLocation
    public var calloutImage: UIImage?
    public var anchor: MBARAnchor?
    var place: Place?
    
    public init(location: CLLocation, calloutImage: UIImage?) {
        self.location = location
        self.calloutImage = calloutImage
    }
    
    init(location: CLLocation, calloutImage: UIImage?, place: Place?) {
        self.location = location
        self.calloutImage = calloutImage
        self.place = place
    }
    
}
