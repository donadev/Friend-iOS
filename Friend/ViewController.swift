//
//  ViewController.swift
//  Friend
//
//  Created by Luigi Donadel on 20/01/16.
//  Copyright © 2016 Luigi Donadel. All rights reserved.
//

import UIKit
class ViewController: UIViewController, OEEventsObserverDelegate {

    let activator = FriendActivator()
    let halo = PulsingHaloLayer(layerNumber: 5)
    let activeColor = UIColor(red: 0, green: 0.455, blue: 0.756, alpha: 1)
    let inactiveColor = UIColor.grayColor()
    let speechColor = UIColor.greenColor()
    var active = false
    
    @IBOutlet var statusLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        halo.position = self.view.center
        self.view.layer.addSublayer(halo)
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        activator.bind(self)
        activator.configure()
        activator.listen()
    }
    override func viewDidDisappear(animated: Bool) {
        activator.shuwdown()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func pocketsphinxFailedNoMicPermissions() {
        print("Failed, no mic")
        statusLabel.text = "No mic found"
        statusLabel.textColor = UIColor.redColor()
    }
    func audioInputDidBecomeAvailable() {
        activator.listen()
    }
    func pocketsphinxDidReceiveHypothesis(hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        if activator.isActivatingOrder(hypothesis) {
            halo.color = activeColor.CGColor
            statusLabel.textColor = activeColor
            statusLabel.text = "Hi :) Need something?"
            active = true
        } else if activator.isShuttingDownOrder(hypothesis) {
            
            statusLabel.textColor = inactiveColor
            statusLabel.text = "Bye bye"
            halo.color = inactiveColor.CGColor
            active = false
        }
    }
    func pocketsphinxDidDetectSpeech() {
        halo.pulseInterval = 0.02
        if !active {
            halo.color = speechColor.CGColor
            statusLabel.textColor = speechColor
            statusLabel.text = "Listening..."
        }
    }
    func pocketsphinxDidDetectFinishedSpeech() {
        halo.pulseInterval = 0.1
        if !active {
            halo.color = inactiveColor.CGColor
            statusLabel.textColor = inactiveColor
            statusLabel.text = "Can't hear anything"
        }
    }

}

