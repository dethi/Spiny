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
let changeAudioSettingKey = "fr.dethi.Spiny.changeAudioSettings"

class GameViewController: UIViewController, AVAudioPlayerDelegate, GKGameCenterControllerDelegate {
    var scene: GameScene!
    
    var audioPlayer: AVAudioPlayer?
    var currentSoundsIndex = 0
    var soundsPlaylist = [NSURL]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Game Center
        
        authenticateLocalPlayer()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.showLeaderboards), name: showGameCenterKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.saveScore as (GameViewController) -> () -> ()), name: saveScoreKey, object: nil)

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
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.handleAudioSetting), name: AVAudioSessionSilenceSecondaryAudioHintNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.handleAudioSetting), name: changeAudioSettingKey, object: nil)
        
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

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
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
        if let audioPlayer = try? AVAudioPlayer(contentsOfURL: soundsPlaylist[currentSoundsIndex]) {
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        currentSoundsIndex = (currentSoundsIndex + 1) % soundsPlaylist.count
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
            let scoreReporter = GKScore(leaderboardIdentifier: "spiny_high_score")
            
            scoreReporter.value = Int64(score)
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.reportScores(scoreArray) {(error : NSError?) -> Void in
                if error != nil {
                    print(error)
                }
            }
        }
    }
    
    func showLeaderboards() {
        let vc = self.view?.window?.rootViewController
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        vc?.presentViewController(gc, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController)
    {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func authenticateLocalPlayer(){
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if (viewController != nil) {
                self.presentViewController(viewController!, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: -
    
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
