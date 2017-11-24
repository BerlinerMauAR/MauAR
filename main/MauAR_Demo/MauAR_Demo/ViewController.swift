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
    private var photoNode_ = SCNNode()
//    var planeNode                 = SCNNode()
    var isWallCreated_                       = false
    var horizontalHelperNodes_ : [ SCNNode ] = []

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

    func renderer( _ renderer : SCNSceneRenderer, didAdd node : SCNNode, for anchor : ARAnchor )
    {
        if !isWallCreated_
        {
            if anchor is ARPlaneAnchor
            {
                let planeAnchor = anchor as! ARPlaneAnchor  //downcast anchor type
                let planeGeom   = SCNPlane( width: CGFloat( planeAnchor.extent.x ),
                                            height: CGFloat( planeAnchor.extent.z ) ) //NOTE! Z not Y
                let planeNode   = SCNNode( geometry: planeGeom )
                planeNode.name = "Plane horizontal detected"

                planeNode.transform = SCNMatrix4MakeRotation( -Float.pi / 2, 1, 0, 0 ) // make horizontal
                planeNode.position = SCNVector3( planeAnchor.center.x, 0, planeAnchor.center.z ) // y = 0
                print( "Anchor found in: " )
                print( planeNode.position )
                planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor( red: 0, green: 0, blue: 0, alpha: 0.3 )
                planeNode.geometry?.firstMaterial?.isDoubleSided = true

                node.addChildNode( planeNode ) //Node created when plane is found
                horizontalHelperNodes_.append( planeNode )
            }
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
                if !isWallCreated_
                {
                    isWallCreated_ = true
                    let transform            = hitResult.worldTransform.columns.3
                    let worldCoordinateTouch = SCNVector3( transform.x,
                                                           transform.y,
                                                           transform.z )

                    var coordPhoto = worldCoordinateTouch
                    coordPhoto.y += 1.4
                    drawPicture( position: coordPhoto )
//                    drawWall( position: worldCoordinateTouch )

                // --- hide all helper planes
                    for node in horizontalHelperNodes_
                    {
                        node.isHidden = true
                    }
                }
            }
        }
    }

    private func drawWall( position : SCNVector3 )
    {
        let scene = SCNScene( named: "art.scnassets/MauerEinfach scaling copy.scn" )!
        if let node = scene.rootNode.childNode( withName: "MauerEinfach", recursively: true )
        {
            mauerNode_ = node
        } else
        {
            print( "No wall found" )
        }

        mauerNode_.position = position
        sceneView.scene.rootNode.addChildNode( mauerNode_ )
        print( "Touch - Plane World Coord \( position )" )
    }


    private func drawPicture( position : SCNVector3 )
    {
        photoNode_.name = "Foto mit Pfeil"

        let planeHeight : CGFloat = 0.2
        let photoPlane            = SCNNode( geometry: SCNPlane( width: 0.3, height: planeHeight ) )
        let photoPlaneBack        = SCNNode( geometry: SCNPlane( width: 0.3, height: planeHeight ) )
        photoPlane.geometry?.firstMaterial?.diffuse.contents = UIImage( named: "Stiftung-Berliner-Mauer-f-021026.jpg" )
        photoPlaneBack.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        photoPlaneBack.eulerAngles.y = Float.pi //Turn around
        photoPlaneBack.position.z -= 0.0001

        if let scene = SCNScene( named: "Pfeil.dae" )
        {
            if let pfeilNode = scene.rootNode.childNode( withName: "Pfeil", recursively: true )
            {
                pfeilNode.position.y += Float( planeHeight ) / 2
                let moveUp   = SCNAction.move( by: SCNVector3( 0, 0.2, 0 ), duration: 0.5 )
                let moveDown = SCNAction.move( by: SCNVector3( 0, -0.2, 0 ), duration: 0.5 )
                moveUp.timingMode = .easeOut
                moveDown.timingMode = .easeIn
                let zappel = SCNAction.repeatForever( SCNAction.sequence( [ moveUp, moveDown ] ) )
                pfeilNode.runAction( zappel )

                photoNode_.addChildNode( pfeilNode )
            } else
            {
                print( "No pfeil node found" )
            }
        } else
        {
            print( "Could not load Pfeil" )
        }

        photoNode_.position = position
        photoNode_.addChildNode( photoPlane )
        photoNode_.addChildNode( photoPlaneBack )
        sceneView.scene.rootNode.addChildNode( photoNode_ )
    }
}
