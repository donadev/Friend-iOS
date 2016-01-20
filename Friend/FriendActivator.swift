//
//  FriendActivator.swift
//  Friend
//
//  Created by Luigi Donadel on 20/01/16.
//  Copyright © 2016 Luigi Donadel. All rights reserved.
//

import UIKit

class FriendActivator {
    private let modelName = "friendActivatorModel"
    private let languageSet = "AcousticModelEnglish"
    
    private static let defaultOrder = "HEY FRIEND"
    private static let orderKey = "FRIEND_ORDER"
    
    private static let sharedInstance = FriendActivator()
    private var languageModelPath : String!
    private var languageDictPath : String!
    
    let generator = OELanguageModelGenerator()
    let observer = OEEventsObserver()
    
    class func getOrder() -> String {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let order = userDefaults.stringForKey(orderKey) {
            return order
        }
        return defaultOrder
    }
    class func changeOrder(order : String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(order, forKey: orderKey)
        userDefaults.synchronize()
        sharedInstance.shuwdown()
        sharedInstance.configure(order)
        sharedInstance.listen()
    }
    func isOrderMade(order : String) -> Bool {
        return order == FriendActivator.getOrder()
    }
    func bind(delegate : OEEventsObserverDelegate) {
        self.observer.delegate = delegate
        try! OEPocketsphinxController.sharedInstance().setActive(true)
    }
    func configure(order : String) {
        let languagePath = OEAcousticModel.pathToModel(languageSet)
        if let error = generator.generateLanguageModelFromArray([order], withFilesNamed: modelName, forAcousticModelAtPath: languagePath) {
            print("Error: \(error)")
        }
    }
    func configure() {
        let order = FriendActivator.getOrder()
        configure(order)
    }
    func shuwdown() {
        let controller = OEPocketsphinxController.sharedInstance()
        if let error = controller.stopListening() {
            print("Problem with shutting down listener : \(error)")
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
