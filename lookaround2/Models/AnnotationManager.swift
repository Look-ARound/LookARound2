//
//  AugmentedViewController.swift
//  lookaround2
//
//  Created by Angela Yu on 10/20/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//  Forked from MapBox + ARKit by MapBox at https://github.com/mapbox/mapbox-arkit-ios
//

import ARKit
import CoreLocation
import Mapbox

@objc public protocol AnnotationManagerDelegate {
    
    @objc optional func node(for annotation: Annotation) -> SCNNode?
    @objc optional func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera)
    
}

public class AnnotationManager: NSObject {
    
    public private(set) var session: ARSession
    public private(set) var sceneView: ARSCNView?
    public private(set) var anchors = [ARAnchor]()
    public private(set) var annotationsByAnchor = [ARAnchor: Annotation]()
    public private(set) var annotationsByNode = [SCNNode: Annotation]()
    public var delegate: AnnotationManagerDelegate?
    public var originLocation: CLLocation?
    
    public init(session: ARSession) {
        self.session = session
    }
    
    convenience public init(sceneView: ARSCNView) {
        self.init(session: sceneView.session)
        session = sceneView.session
        sceneView.delegate = self
    }
    
    public func addAnnotation(annotation: Annotation) {
        guard let originLocation = originLocation else {
            print("Warning: \(type(of: self)).\(#function) was called without first setting \(type(of: self)).originLocation")
            return
        }
        
        // Create a Mapbox AR anchor anchor at the transformed position
        let anchor = LookAnchor(originLocation: originLocation, location: annotation.location)
        
        // Add the anchor to the session
        session.add(anchor: anchor)
        
        anchors.append(anchor)
        annotation.anchor = anchor
        annotationsByAnchor[anchor] = annotation
    }
    
    public func addAnnotations(annotations: [Annotation]) {
        for annotation in annotations {
            addAnnotation(annotation: annotation)
        }
    }
    
    public func removeAllAnnotations() {
        for anchor in anchors {
            session.remove(anchor: anchor)
        }
        
        anchors.removeAll()
        annotationsByAnchor.removeAll()
    }
    
    public func removeAnnotations(annotations: [Annotation]) {
        for annotation in annotations {
            removeAnnotation(annotation: annotation)
        }
    }
    
    public func removeAnnotation(annotation: Annotation) {
        if let anchor = annotation.anchor {
            session.remove(anchor: anchor)
            anchors.remove(at: anchors.index(of: anchor)!)
            annotationsByAnchor.removeValue(forKey: anchor)
        }
    }
    
}

// MARK: - ARSCNViewDelegate

extension AnnotationManager: ARSCNViewDelegate {
    
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        delegate?.session?(session, cameraDidChangeTrackingState: camera)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Handle LookAnchor
        if let anchor = anchor as? LookAnchor {
            let annotation = annotationsByAnchor[anchor]!
            
            var newNode: SCNNode!
            
            // If the delegate supplied a node then use that, otherwise provide a basic default node
            if let suppliedNode = delegate?.node?(for: annotation) {
                newNode = suppliedNode
                //newNode = createDefaultNode()
            } else {
                newNode = createDefaultNode()
            }
            
            if let calloutImage = annotation.calloutImage {
                let calloutNode = createCalloutNode(with: calloutImage, node: newNode)
                newNode.addChildNode(calloutNode)
            }
            else {
                let calloutNode = createDefaultCallout(using: annotation, for: newNode)
                newNode.addChildNode(calloutNode)
            }
            
            node.addChildNode(newNode)
            
            annotationsByNode[newNode] = annotation
        }
        
        // TODO: let delegate provide a node for a non-MBARAnchor
    }
    
    // MARK: - Utility methods for ARSCNViewDelegate
    
    func createDefaultNode() -> SCNNode {
        let geometry = SCNSphere(radius: 0.2)
        // let geometry = SCNSphere(radius: 1.0)
        geometry.firstMaterial?.diffuse.contents = UIColor.yellow
        return SCNNode(geometry: geometry)
    }
    
    func createCalloutNode(with image: UIImage, node: SCNNode) -> SCNNode {
        
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        
        if image.size.width >= image.size.height {
            width = 2.0 * (image.size.width / image.size.height)
            height = 2.0
        } else {
            width = 2.0
            height = 2.0 * (image.size.height / image.size.width)
        }
        
        let calloutGeometry = SCNPlane(width: width, height: height)
        calloutGeometry.firstMaterial?.diffuse.contents = image
        
        let calloutNode = SCNNode(geometry: calloutGeometry)
        var nodePosition = node.position
        let (min, max) = node.boundingBox
        let nodeHeight = max.y - min.y
        nodePosition.y = nodeHeight + 2.0
        
        calloutNode.position = nodePosition
        
        let constraint = SCNBillboardConstraint()
        constraint.freeAxes = [.Y]
        calloutNode.constraints = [constraint]
        
        return calloutNode
    }
    
    func createDefaultCallout(using annotation: Annotation, for node: SCNNode) -> SCNNode {
        
        guard let annotationTitle = annotation.title else {
            return SCNNode()
        }
        var calloutString = annotationTitle
        if let friendsCount = annotation.place?.contextCount {
            if friendsCount > 0 {
                calloutString += " (\(friendsCount))"
            }
        }
        let title = SCNText(string: calloutString, extrusionDepth: 0)
        title.font = UIFont.systemFont(ofSize: 1.5, weight: .bold)
        
        let callout = AugmentedCalloutView(for: annotation)
        let geoWidth = callout.frame.size.width / 20
        let geoHeight = callout.frame.size.height / 20
        
        let calloutGeometry = SCNPlane(width: geoWidth, height: geoHeight)
        
        //calloutGeometry.firstMaterial?.fillMode = .fill
        calloutGeometry.firstMaterial?.diffuse.contents = callout

        let calloutNode = SCNNode(geometry: calloutGeometry)
        var nodePosition = node.position
        let (cmin, cmax) = calloutNode.boundingBox
        let (min, max) = node.boundingBox
        let calloutWidth = cmax.x - cmin.x
        nodePosition.y = max.y + 2.0
        nodePosition.x -= calloutWidth/2
        
        calloutNode.position = nodePosition
        
        let constraint = SCNBillboardConstraint()
        constraint.freeAxes = [.Y]
        calloutNode.constraints = [constraint]
        
        return calloutNode
    }
    
}
