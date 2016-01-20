//
//  ViewController.swift
//  Friend
//
//  Created by Luigi Donadel on 20/01/16.
//  Copyright © 2016 Luigi Donadel. All rights reserved.
//

import UIKit
class ViewController: UIViewController, OEEventsObserverDelegate {

    var observer : OEEventsObserver!
    var sphinxController : OEPocketsphinxController!
    let generator = OELanguageModelGenerator()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observer = OEEventsObserver()
        self.observer.delegate = self
        try! OEPocketsphinxController.sharedInstance().setActive(true)
        self.generateLanguage()
        self.listen()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    func generateLanguage() {
        generator.verboseLanguageModelGenerator = true
        let path = NSBundle.mainBundle().pathForResource("AcousticModelEnglish", ofType: "bundle")
        let _ = generator.generateLanguageModelFromArray(["HEY FRIEND"], withFilesNamed: "startupModel", forAcousticModelAtPath: path)

    }
    func listen() {
        let controller = OEPocketsphinxController.sharedInstance()
        if !controller.isListening {
            let languageModel = generator.pathToSuccessfullyGeneratedLanguageModelWithRequestedName("startupModel")
            let languageDict = generator.pathToSuccessfullyGeneratedDictionaryWithRequestedName("startupModel")
            let model = OEAcousticModel.pathToModel("AcousticModelEnglish")
            controller.startListeningWithLanguageModelAtPath(languageModel, dictionaryAtPath: languageDict, acousticModelAtPath: model, languageModelIsJSGF: false)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func pocketsphinxFailedNoMicPermissions() {
        print("Failed, no mic")
    }
    func audioInputDidBecomeAvailable() {
        self.listen()
    }
    func pocketsphinxDidReceiveHypothesis(hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        print(hypothesis)
    }
    func pocketsphinxDidDetectSpeech() {
        print("Speech detected")
    }

}

