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
    var planeNode_        = SCNNode()
    var isShownMainObject = false

    override func viewDidLoad()
    {
        super.viewDidLoad()
        sceneView.delegate = self
//        sceneView.showsStatistics = true
//        sceneView.debugOptions = [ ARSCNDebugOptions.showFeaturePoints ]
    }

    override func viewWillAppear( _ animated : Bool )
    {
        super.viewWillAppear( animated )
        sceneView.autoenablesDefaultLighting = true

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
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

    func renderer( _ renderer : SCNSceneRenderer, didAdd node : SCNNode, for anchor : ARAnchor )
    {
        if anchor is ARPlaneAnchor
        {
            let planeAnchor = anchor as! ARPlaneAnchor  //downcast anchor type
            let planeGeom   = SCNPlane( width: CGFloat( planeAnchor.extent.x ),
                                        height: CGFloat( planeAnchor.extent.z ) ) //NOTE! Z not Y
            planeNode_ = SCNNode( geometry: planeGeom )
            planeNode_.name = "Plane horizontal detected"

            planeNode_.transform = SCNMatrix4MakeRotation( -Float.pi / 2, 1, 0, 0 ) // make horizontal
            planeNode_.position = SCNVector3( planeAnchor.center.x, 0, planeAnchor.center.z ) // y = 0
            print( "Anchor found in: " )
            print( planeNode_.position )
            planeNode_.geometry?.firstMaterial?.diffuse.contents = UIColor( red: 0, green: 0, blue: 0, alpha: 0.3 )
            planeNode_.geometry?.firstMaterial?.isDoubleSided = true

            node.addChildNode( planeNode_ ) //Node created when plane is found
        }
    }

    override func touchesBegan( _ touches : Set<UITouch>, with event : UIEvent? )
    {
        if let touch = touches.first
        {
            let touchLocation = touch.location( in: sceneView )
            let resultsPlane  = sceneView.hitTest( touchLocation, types: .existingPlaneUsingExtent )

            if let hitResult = resultsPlane.first
            {
                if !isShownMainObject  //TODO shorter syntax
                {
//                    isShownMainObject = true
                    let scene = SCNScene( named: "art.scnassets/MauerEinfach scaling copy.scn" )!
                    if let node = scene.rootNode.childNode( withName: "MauerEinfach", recursively: true )
                    {
                        mauerNode_ = node
                    } else
                    {
                        print( "No wall found" )
                    }

                    let transform            = hitResult.worldTransform.columns.3
                    let worldCoordinateTouch = SCNVector3( transform.x,
                                                           transform.y,
                                                           transform.z )

                    mauerNode_.position = worldCoordinateTouch
                    sceneView.scene.rootNode.addChildNode( mauerNode_ )
                    print( "Touch - Plane World Coord \( worldCoordinateTouch )" )
                }
            }
        }
    }

}
