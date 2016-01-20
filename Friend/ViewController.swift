//
//  ViewController.swift
//  Friend
//
//  Created by Luigi Donadel on 20/01/16.
//  Copyright © 2016 Luigi Donadel. All rights reserved.
//

import UIKit
class ViewController: UIViewController, OEEventsObserverDelegate {

    var activator : FriendActivator!
    override func viewDidLoad() {
        super.viewDidLoad()
        activator = FriendActivator(delegate: self)
        activator.listen()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func pocketsphinxFailedNoMicPermissions() {
        print("Failed, no mic")
    }
    func audioInputDidBecomeAvailable() {
        activator.listen()
    }
    func pocketsphinxDidReceiveHypothesis(hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        if activator.isOrderMade(hypothesis) {
            print("matched!")
        }
    }
    func pocketsphinxDidDetectSpeech() {
        print("Speech detected")
    }

}

