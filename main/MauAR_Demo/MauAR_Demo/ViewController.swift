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
    private var mauerNode_    = SCNNode()
    private var photoNode_    = SCNNode()
    private var infoTextNode_ = SCNNode()
//    var planeNode                 = SCNNode()
    var isWallCreated_                       = false
    var isInfoHidden_                        = true
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
            let resultsAll    = sceneView.hitTest( touchLocation )

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
                    coordPhoto.x += -1.0
                    coordPhoto.y += 1.4
                    coordPhoto.z += 2
                    drawPicture( position: coordPhoto )
                    drawWall( position: worldCoordinateTouch )

                    // --- hide all helper planes
                    for node in horizontalHelperNodes_
                    {
                        node.isHidden = true
                    }
                }
            }

            if let hitResultFirst = resultsAll.first
            {
                if let name = hitResultFirst.node.name
                {
                    // --- switch
                    if ( name == "Info" ) || ( name == "Foto" )
                    {
                        let fadeDuration = 0.2
                        let fadeIn       = SCNAction.fadeIn( duration: fadeDuration )
                        let fadeOut      = SCNAction.fadeOut( duration: fadeDuration )
                        let moveIn       = SCNAction.move( to: SCNVector3( 0, 0, 0.03 ), duration: fadeDuration )
                        let moveOut      = SCNAction.move( to: SCNVector3( 0, 0, 0.0 ), duration: fadeDuration )
                        let scaleIn      = SCNAction.scale( to: 1.0, duration: fadeDuration )
                        let scaleOut     = SCNAction.scale( to: 0.3, duration: fadeDuration )
                        fadeIn.timingMode = .easeOut
                        moveIn.timingMode = .easeOut
                        scaleIn.timingMode = .easeOut
                        fadeOut.timingMode = .easeIn
                        moveOut.timingMode = .easeIn
                        scaleOut.timingMode = .easeIn

                        let appear = SCNAction.group( [ fadeIn, moveIn, scaleIn ] )
                        let disappear = SCNAction.group( [ fadeOut, moveOut, scaleOut ] )

                        if isInfoHidden_
                        {
                            infoTextNode_.runAction( appear )
                            print( "Info : an" )
                        } else
                        {
                            infoTextNode_.runAction( disappear )
                            print( "Info : aus" )
                        }

                        isInfoHidden_ = !isInfoHidden_
                    }

                    print( "Name: \( name )" )
                } else
                {
                    print( "No name of this object" )
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
        photoPlane.name = "Foto"
        photoPlane.geometry?.firstMaterial?.diffuse.contents = UIImage( named: "Stiftung-Berliner-Mauer-f-021026.jpg" )
        photoPlaneBack.name = "Background"
        photoPlaneBack.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        photoPlaneBack.eulerAngles.y = Float.pi //Turn around
        photoPlaneBack.position.z -= 0.0001

        infoTextNode_ = SCNNode( geometry: SCNPlane( width: 0.3, height: planeHeight ) )
        infoTextNode_.name = "Info"
//        infoTextNode_.position.z += 0.03
        infoTextNode_.simdScale *= 0.3
        infoTextNode_.geometry?.firstMaterial?.diffuse.contents = UIImage( named: "InfoOverlay.png" )
        infoTextNode_.geometry?.firstMaterial?.transparency = 1.0
        infoTextNode_.geometry?.firstMaterial?.isDoubleSided = true
        infoTextNode_.runAction( SCNAction.fadeOut( duration: 0 ) )


        if let scene = SCNScene( named: "Pfeil.dae" )
        {
            if let pfeilNode = scene.rootNode.childNode( withName: "Pfeil", recursively: true )
            {
                pfeilNode.name = "Pfeil"
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
        photoNode_.addChildNode( infoTextNode_ )
        sceneView.scene.rootNode.addChildNode( photoNode_ )
    }
}
