//
// Created by Peter A. Kolski on 06.11.17.
// Copyright (c) 2017 Peter Kolski. All rights reserved.
//

import Foundation

/*
private func peterTouchInteraction( touches : Set<UITouch> )
    { //        super.touchesBegan( touches, with: event )
        if let touch = touches.first
        {
            os_log( "One touch", log: ViewController.log_UI, type: .debug )
            let touchLocation = touch.location( in: sceneView )
            let resultsPlane  = sceneView.hitTest( touchLocation, types: .existingPlaneUsingExtent )
            let resultsAll    = sceneView.hitTest( touchLocation )

            if let hitResult = resultsPlane.first
            {
                os_log( "Touched a vertical plane", log: ViewController.log_UI, type: .debug )

                if !isShownMainObject  //TODO shorter syntax
                {
                    isShownMainObject = true

                    // --- All the subNodes of the model + optional unwrapping
                    if let nodeMain = sceneMainObject?.rootNode.childNode( withName: nameMainObject, recursively: true )
                    {
                        let radiusBounding = nodeMain.boundingSphere.radius * 2
                        // --- Last column is pos --- Move up the object
                        let position       = SCNVector3( x: hitResult.worldTransform.columns.3.x,
//                                                         y: hitResult.worldTransform.columns.3.y + nodeMain.boundingSphere.radius,
                                                         y: hitResult.worldTransform.columns.3.y,
                                                         z: hitResult.worldTransform.columns.3.z )

                        createNode( sceneView: sceneView, node: nodeMain, position: position )
                        createBox( sceneView: sceneView, radiusBounding: radiusBounding, position: position, nameBox: nameBox )
                        os_log( "Object created", log: ViewController.log_SCN, type: .debug )

                        smBox.applyTrigger( TriggerBox.TouchedFloor )
//                        labelBoxState.text = String( "BoxState: " + smBox.getStateStr() )
                        os_log( "Box State = %@", log: ViewController.log_STATE, type: .default, smBox.getStateStr() )

                        CreateVidPic( position: position )
                    } else
                    {
                        os_log( "Object NOT created", log: ViewController.log_SCN, type: .error )
                    }
                }
            }

            if let hitResultFirst = resultsAll.first
            {
                os_log( "Touched any object", log: ViewController.log_UI, type: .debug )
                let worldCoord : SCNVector3 = hitResultFirst.worldCoordinates
                let projPoint               = sceneView.projectPoint( worldCoord )
                let unProjPoint             = sceneView.unprojectPoint( projPoint )
                print( "TouchLocation \( touchLocation )" )
                print( "Object World Coord \( worldCoord )" )
                print( "Projected point: \( projPoint )" )
                print( "Unprojected point: \( unProjPoint )" )

                if let name = hitResultFirst.node.name
                {
                    os_log( "HitResult: Name of the node = %@", log: ViewController.log_UI, type: .debug, name )
                } else
                {
                    os_log( "No name of this object", log: ViewController.log_UI, type: .debug )
                }

                // --- Check if it was the box
                if let nodeName : String = hitResultFirst.node.name
                {
                    if nodeName == nameBox
                    {
                        smBox.applyTrigger( TriggerBox.TouchedBox )
//                        labelBoxState.text = String( "BoxState: " + smBox.getStateStr() )
                        createBallAtBox( sceneView: sceneView, worldCoord: worldCoord )
                        playBoxSound()
                    }
                }
            }
        }
    }
*/


/*
    private func CreateVidPic( position : SCNVector3 )
    {
        let videoName      = "GlasFull"
        let videoNameMask  = "GlasMask"
        let videoExtension = "mov"
        let picName        = "art.scnassets/Slap.jpg"

        guard let videoUrlMask = Bundle.main.url( forResource: videoNameMask, withExtension: videoExtension )
                else
        {
            os_log( "Video not loaded videoName = %@ --- in xCode bundle?", log: ViewController.log_MEDIA, type: .debug, videoNameMask )
            return
        }

        //  --- Create the SpriteKit video node, containing the video player
        // A SpriteKit scene to contain the SpriteKit video node
        let videoPlayerMask = AVPlayer( url: videoUrlMask )
        let skSceneMask     = SKScene( size: CGSize( width: sceneView.frame.width, height: sceneView.frame.height ) )
        skSceneMask.scaleMode = .aspectFit
        let nodeSKVidMask = SKVideoNode( avPlayer: videoPlayerMask )
        nodeSKVidMask.position = CGPoint( x: skSceneMask.size.width / 2.0, y: skSceneMask.size.height / 2.0 )
        nodeSKVidMask.size = skSceneMask.size
        nodeSKVidMask.yScale = -1.0
        nodeSKVidMask.play()
        skSceneMask.addChild( nodeSKVidMask )

        guard let videoUrl = Bundle.main.url( forResource: videoName, withExtension: videoExtension )
                else
        {
            os_log( "Video not loaded videoName = %@ --- in xCode bundle?", log: ViewController.log_MEDIA, type: .debug, videoName )
            return
        }

        let videoPlayerFull = AVPlayer( url: videoUrl )
        let skScene         = SKScene( size: CGSize( width: sceneView.frame.width, height: sceneView.frame.height ) )
        skScene.scaleMode = .aspectFit
        let nodeSKVid = SKVideoNode( avPlayer: videoPlayerFull )
        nodeSKVid.position = CGPoint( x: skScene.size.width / 2.0, y: skScene.size.height / 2.0 )
        nodeSKVid.size = skScene.size
        nodeSKVid.yScale = -1.0
        nodeSKVid.play()
        skScene.addChild( nodeSKVid )


        let planeVid = SCNPlane( width: CGFloat( 100 ), height: CGFloat( 100 ) )
        planeVid.firstMaterial?.diffuse.contents = skScene   // Put the sprite into a plane
//        planeVid.firstMaterial?.transparencyMode = SCNTransparencyMode.aOne //using alpha
        planeVid.firstMaterial?.transparencyMode = SCNTransparencyMode.rgbZero //using luminance
        planeVid.firstMaterial?.transparent.contents = skSceneMask
        planeVid.height = 0.1
        planeVid.width = 0.1
        let nodeVid               = SCNNode( geometry: planeVid )
        let planeDist :     Float = 0.2
        let heightOverBox : Float = 0.2
        let depth :         Float = 0.2
        nodeVid.position = SCNVector3( position.x - planeDist, position.y + heightOverBox, position.z - depth )

        // --- Place with a picture
        let planePic = SCNPlane( width: CGFloat( 100 ), height: CGFloat( 100 ) )
        planePic.firstMaterial?.diffuse.contents = UIImage( named: picName )
        planePic.height = 0.1
        planePic.width = 0.1
        let nodePic = SCNNode( geometry: planePic )
        nodePic.position = SCNVector3( position.x + planeDist, position.y + heightOverBox, position.z - depth )

        // --- Add nodes to the scene and scene to the view
        sceneView.isPlaying = true
        sceneView.scene.rootNode.addChildNode( nodePic )
        sceneView.scene.rootNode.addChildNode( nodeVid )
        os_log( "Video loaded", log: ViewController.log_MEDIA, type: .debug )
    }

*/

/*
    private func playBoxSound()
    {
        let nameSoundFile = "note1"
        guard let url = Bundle.main.url( forResource: nameSoundFile, withExtension: "wav" )
                else
        {
            os_log( "Sound File NOT found with nameSoundFile = %@", log: ViewController.log_MEDIA, type: .error, nameSoundFile )
            return
        }

        do
        {
            audioPlayer = try AVAudioPlayer( contentsOf: url )
            audioPlayer!.play()
            os_log( "Sound playing from nameSoundFile = %@", log: ViewController.log_MEDIA, type: .debug, nameSoundFile )
        } catch let error
        {
            os_log( "Sound not played", log: ViewController.log_MEDIA, type: .error )
            print( error )
        }
    }
*/

//func playBoxSound( audioPlayer:AVAudioPlayer, fileName:String)
//{
//    guard let url = Bundle.main.url( forResource: fileName, withExtension: "wav" )
//    else
//    {
//        print( "Sound file url not found" )
//        return
//    }
//
//    do
//    {
//        audioPlayer = try AVAudioPlayer( contentsOf: url )
//        audioPlayer!.play()
//        print( "Sound playing" )
//    } catch let error
//    {
//        print( error )
//    }
//}