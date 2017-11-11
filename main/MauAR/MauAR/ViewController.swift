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

class ViewController: UIViewController, CLLocationManagerDelegate, ARSCNViewDelegate, ARSessionDelegate
{
    @IBOutlet weak var coordinateLable : UILabel!
    @IBOutlet weak var sceneView :       ARSCNView!
    var sceneLocationView = SceneLocationView()
    lazy private var locationManager = CLLocationManager()

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.sceneView.delegate = self
        self.sceneView.session.delegate = self
        sceneLocationView.run()
        sceneView.addSubview( sceneLocationView )
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        print( self.locationManager.location?.coordinate )


        // BBTor = Brandenburger Tor
        //lat - Breite / Verlauf: O-W / Winkel +- Equator
        //long - Länge / Verlauf: N-S / Winkel +- Nullmeridian (Greenwich)
        let coordBBtor    = CLLocationCoordinate2D( latitude: 52.516275, longitude: 13.377704 )
        let locationBBTor = CLLocation( coordinate: coordBBtor, altitude: 40 )
        let imagePin      = UIImage( named: "pin" )
        let nodeBBTor     = LocationAnnotationNode( location: locationBBTor, image: imagePin! )
        nodeBBTor.scaleRelativeToDistance = false

        sceneLocationView.addLocationNodeWithConfirmedLocation( locationNode: nodeBBTor )
        createWall()
    }

    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = sceneView.bounds
    }

    fileprivate func createWall()
    {
        if let scene = SCNScene( named: "art.scnassets/BerlinWall.scn" )
        {
            sceneView.scene = scene
            if let nodeWall = scene.rootNode.childNode( withName: "Wall", recursively: true )
            {
                sceneLocationView.scene.rootNode.addChildNode( nodeWall )

                print( "Loaded wall\n" )
            } else
            {
                print( "Not found name of node" )
            }
        } else
        {
            print( "Wall not loaded\n" )
        }
    }

//    func session( _ session : ARSession, didUpdate frame : ARFrame )
    func renderer( _ renderer : SCNSceneRenderer, didRenderScene scene : SCNScene, atTime time : TimeInterval )
    {
        if let coordinate = self.locationManager.location?.coordinate
        {
//            self.coordinateLable.text = String( coordinate.latitude ) + " : " + String( coordinate.longitude )
            self.coordinateLable.text = String( coordinate.latitude ) + " : " + String( coordinate.longitude )
            print("in")
        }
        print("out")
    }
}

