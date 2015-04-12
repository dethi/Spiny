//
//  GameViewController.swift
//  Spiny
//
//  Created by Thibault Deutsch on 10/04/15.
//  Copyright (c) 2015 Thibault Deutsch. All rights reserved.
//

import UIKit
import AVFoundation
import SpriteKit

class GameViewController: UIViewController, AVAudioPlayerDelegate {
    var audioPlayer: AVAudioPlayer?
    var currentSoundsIndex = 0
    var soundsPlaylist = [NSURL]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = GameScene()
        scene.size = view.frame.size
        
        let skView = self.view as! SKView
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
        
        // Setup sounds
        
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSilenceSecondaryAudioHintNotification", name: AVAudioSessionSilenceSecondaryAudioHintNotification, object: nil)
        
        soundsPlaylist.reserveCapacity(3)
        
        for i in 0...2 {
            let sound = NSBundle.mainBundle().URLForResource("track_menu\(i)", withExtension: "caf")
            soundsPlaylist.append(sound!)
        }
        
        if !AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint {
            playCurrentSound()
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Audio Player
    
    func playCurrentSound() {
        var error: NSError?
        audioPlayer = AVAudioPlayer(contentsOfURL: soundsPlaylist[currentSoundsIndex], error: &error)
        
        if let audioPlayer = audioPlayer {
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } else {
            println(error)
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        currentSoundsIndex = ++currentSoundsIndex % soundsPlaylist.count
        playCurrentSound()
    }
    
    func handleSilenceSecondaryAudioHintNotification() {
        if AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint {
            if let audioPlayer = audioPlayer {
                if audioPlayer.playing {
                    audioPlayer.stop()
                }
            }
        } else {
            playCurrentSound()
        }
    }
    
    // MARK: -
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
