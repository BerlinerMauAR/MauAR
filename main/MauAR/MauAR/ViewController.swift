//
//  ViewController.swift
//  MauAR
//
//  Created by Peter A. Kolski on 22.10.17.
//  Copyright © 2017 Peter A. Kolski. All rights reserved.
//

import UIKit
import ARKit
import ARCL
import CoreLocation
import SceneKit

class ViewController: UIViewController, CLLocationManagerDelegate  {
    @IBOutlet weak var sceneView: ARSCNView!
    var sceneLocationView = SceneLocationView()
    lazy private var  locationManager = CLLocationManager()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        sceneLocationView.run()
        sceneView.addSubview( sceneLocationView )
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        print( self.locationManager.location?.coordinate )
        
        //lat - Breite / Verlauf: O-W / Winkel +- Equator
        //long - Länge / Verlauf: N-S / Winkel +- Nullmeridian (Greenwich)
        let coordBBtor = CLLocationCoordinate2D(latitude: 52.516275, longitude: 13.377704)
        let locationBBTor = CLLocation( coordinate: coordBBtor, altitude: 40 )
        let imagePin = UIImage(named: "pin")
        let nodeBBTor = LocationAnnotationNode(location: locationBBTor, image: imagePin! )
        nodeBBTor.scaleRelativeToDistance = false
        
        sceneLocationView.addLocationNodeWithConfirmedLocation( locationNode: nodeBBTor )
        createWall()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = sceneView.bounds
    }
    
    fileprivate func createWall() {
        if let scene = SCNScene(named: "art.scnassets/BerlinWall.scn")
        {
            sceneView.scene = scene
            if let nodeWall = scene.rootNode.childNode(withName: "Wall", recursively: true)
            {
                sceneLocationView.scene.rootNode.addChildNode( nodeWall )
                
                print("Loaded wall\n")
            }
            else{
                print("Not found name of node")
            }
        }
        else
        {
            print( "Wall not loaded\n" )
        }
    }
}

