//
//  FriendActivator.swift
//  Friend
//
//  Created by Luigi Donadel on 20/01/16.
//  Copyright © 2016 Luigi Donadel. All rights reserved.
//

import UIKit

class FriendActivator : NSObject {
    private let modelName = "friendActivatorModel"
    private let languageSet = "AcousticModelEnglish"
    
    private let order = "HEY FRIEND"
    
    private var languageModelPath : String!
    private var languageDictPath : String!
    
    let generator = OELanguageModelGenerator()
    let observer = OEEventsObserver()
    
    init(delegate : OEEventsObserverDelegate) {
        super.init()
        self.observer.delegate = delegate
        try! OEPocketsphinxController.sharedInstance().setActive(true)
    }
    func isOrderMade(order : String) -> Bool {
        return order == self.order
    }
    func configure() {
        let languagePath = OEAcousticModel.pathToModel(languageSet)
        let error = generator.generateLanguageModelFromArray([order], withFilesNamed: modelName, forAcousticModelAtPath: languagePath)
        if let problem = error {
            print("Error: \(problem)")
        }
    }
    func listen() {
        let controller = OEPocketsphinxController.sharedInstance()
        let generator = OELanguageModelGenerator()
        if !controller.isListening {
            languageModelPath = generator.pathToSuccessfullyGeneratedLanguageModelWithRequestedName(modelName)
            languageDictPath = generator.pathToSuccessfullyGeneratedDictionaryWithRequestedName(modelName)
            let model = OEAcousticModel.pathToModel(languageSet)
            controller.startListeningWithLanguageModelAtPath(languageModelPath, dictionaryAtPath: languageDictPath, acousticModelAtPath: model, languageModelIsJSGF: false)
        }
    }
    
}
