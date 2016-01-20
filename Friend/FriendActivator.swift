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
    
    private static let defaultActivatingOrder = "NEED YOUR HELP"
    private static let defaultDeactivatingOrder = "NOT ANYMORE"
    private static let ACTIVATE_ORDER_KEY = "FRIEND_ON_ORDER"
    private static let DEACTIVATE_ORDER_KEY = "FRIEND_OFF_ORDER"
    private static let sharedInstance = FriendActivator()
    private var languageModelPath : String!
    private var languageDictPath : String!
    
    let generator = OELanguageModelGenerator()
    let observer = OEEventsObserver()
    
    class func getOrderKey(activating : Bool) -> String {
        return activating ? ACTIVATE_ORDER_KEY : DEACTIVATE_ORDER_KEY
    }
    class func getDefaultOrder(activating : Bool) -> String {
        return activating ? defaultActivatingOrder : defaultDeactivatingOrder
    }
    class func getOrder(activating : Bool) -> String {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let key = getOrderKey(activating)
        if let order = userDefaults.stringForKey(key) {
            return order
        }
        return getDefaultOrder(activating)
    }
    class func changeOrder(order : String, activating : Bool) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let orderKey = getOrderKey(activating)
        userDefaults.setValue(order, forKey: orderKey)
        userDefaults.synchronize()
        sharedInstance.shuwdown()
        sharedInstance.configure()
        sharedInstance.listen()
    }
    func isActivatingOrder(order : String) -> Bool {
        return order == FriendActivator.getOrder(true)
    }
    func isShuttingDownOrder(order : String) -> Bool {
        return order == FriendActivator.getOrder(false)
    }
    func bind(delegate : OEEventsObserverDelegate) {
        self.observer.delegate = delegate
        try! OEPocketsphinxController.sharedInstance().setActive(true)
    }
    func configure(inOrder : String, outOrder : String) {
        let languagePath = OEAcousticModel.pathToModel(languageSet)
        if let error = generator.generateLanguageModelFromArray([inOrder, outOrder], withFilesNamed: modelName, forAcousticModelAtPath: languagePath) {
            print("Error: \(error)")
        }
    }
    func configure() {
        let inOrder = FriendActivator.getOrder(true)
        let outOrder = FriendActivator.getOrder(false)
        configure(inOrder, outOrder: outOrder)
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
