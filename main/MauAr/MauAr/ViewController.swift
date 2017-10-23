//
//  ViewController.swift
//  MauAr
//
//  Created by Peter A. Kolski on 22.10.17.
//  Copyright © 2017 Peter A. Kolski. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        sceneView.delegate = self as? ARSCNViewDelegate
        let config = ARWorldTrackingConfiguration()
        sceneView.session.run( config )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

