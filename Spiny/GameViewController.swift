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
import GameKit

let showGameCenterKey = "fr.dethi.Spiny.showGameCenter"
let saveScoreKey = "fr.dethi.Spiny.saveScore"
let canDisplayAdsKey = "fr.dethi.Spiny.canDisplatAds"
let changeAudioSettingKey = "fr.dethi.Spiny.changeAudioSettings"

class GameViewController: UIViewController, AVAudioPlayerDelegate, GKGameCenterControllerDelegate {
    var scene: GameScene!
    
    var audioPlayer: AVAudioPlayer?
    var currentSoundsIndex = 0
    var soundsPlaylist = [NSURL]()
    
    var shouldDisplayAds = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup timer for Ads
        
        NSTimer.scheduledTimerWithTimeInterval(60 * 5, target: self, selector: "activateShouldDisplayAds", userInfo: nil, repeats: true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayAds", name: canDisplayAdsKey, object: nil)
        
        // Setup Game Center
        
        authenticateLocalPlayer()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showLeaderboards", name: showGameCenterKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveScore", name: saveScoreKey, object: nil)

        // Setup SpriteKit Scene
        
        scene = GameScene()
        scene.size = view.frame.size
        
        let skView = self.view as! SKView
        
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        //skView.showsDrawCount = true
        
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
        
        // Setup sounds
        
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleAudioSetting", name: AVAudioSessionSilenceSecondaryAudioHintNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleAudioSetting", name: changeAudioSettingKey, object: nil)
        
        soundsPlaylist.reserveCapacity(3)
        
        for i in 0...2 {
            let sound = NSBundle.mainBundle().URLForResource("track_menu\(i)", withExtension: "caf")
            soundsPlaylist.append(sound!)
        }
        
        handleAudioSetting()
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
    
    func handleAudioSetting() {
        if AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint || !scene.playMusic {
            if let audioPlayer = audioPlayer {
                if audioPlayer.playing {
                    audioPlayer.stop()
                }
            }
        } else if scene.playMusic {
            playCurrentSound()
        }
    }
    
    // MARK: - Game Center
    
    func saveScore(score: UInt) {
        if GKLocalPlayer.localPlayer().authenticated {
            var scoreReporter = GKScore(leaderboardIdentifier: "spiny_high_score")
            
            scoreReporter.value = Int64(score)
            var scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.reportScores(scoreArray) {(error : NSError!) -> Void in
                if error != nil {
                    println(error)
                }
            }
        }
    }
    
    func showLeaderboards() {
        var vc = self.view?.window?.rootViewController
        var gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        vc?.presentViewController(gc, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!)
    {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func authenticateLocalPlayer(){
        var localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if (viewController != nil) {
                self.presentViewController(viewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: -
    
    func activateShouldDisplayAds() {
        shouldDisplayAds = true
    }
    
    func displayAds() {
        if shouldDisplayAds {
            shouldDisplayAds = false
            AdBuddiz.showAd()
        }
    }
    
    func saveScore() {
        let score = scene.score
        saveScore(score)
        
        let currentHighScore = NSUserDefaults.standardUserDefaults().valueForKey("highScore") as? UInt
        if score > currentHighScore {
            scene.highScore = score
            NSUserDefaults.standardUserDefaults().setValue(score, forKey: "highScore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
