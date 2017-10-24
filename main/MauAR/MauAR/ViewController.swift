//
//  ViewController.swift
//  MauAR
//
//  Created by Peter A. Kolski on 22.10.17.
//  Copyright © 2017 Peter A. Kolski. All rights reserved.
//

import UIKit
import ARKit
//import ARCL
//import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
//    var sceneLocationView = SceneLocationView()
    let config = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.session.run( config )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

