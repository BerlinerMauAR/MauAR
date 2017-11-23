//
//  ViewController.swift
//  MauAR_Demo
//
//  Created by Peter A. Kolski on 23.11.17.
//  Copyright © 2017 Peter Kolski. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate
{

    @IBOutlet var sceneView : ARSCNView!
    private var mauerNode_ = SCNNode()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true

        let scene = SCNScene( named: "art.scnassets/MauerEinfach scaling copy.scn" )!
        if let node = scene.rootNode.childNode( withName: "MauerEinfach", recursively: true )
        {
            mauerNode_ = node
        }

        mauerNode_.position = SCNVector3( 0, -2.5, -2.0 )

        sceneView.scene = scene
    }

    override func viewWillAppear( _ animated : Bool )
    {
        super.viewWillAppear( animated )
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run( configuration )
    }

    override func viewWillDisappear( _ animated : Bool )
    {
        super.viewWillDisappear( animated )
        sceneView.session.pause()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate

/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/

    func session( _ session : ARSession, didFailWithError error : Error )
    {
        // Present an error message to the user
    }

    func sessionWasInterrupted( _ session : ARSession )
    {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay

    }

    func sessionInterruptionEnded( _ session : ARSession )
    {
        // Reset tracking and/or remove existing anchors if consistent tracking is required

    }
}
