//
//  PreferencesController.swift
//  arvtime
//
//  Created by patman on 1/11/15.
//  Copyright (c) 2015 arvato Systems. All rights reserved.
//

import Foundation
import Cocoa

class PreferencesController : NSWindowController {
        
    @IBOutlet weak var togglApiKeyText: NSTextField!
    
    @IBOutlet weak var catsServerText: NSTextField!
    
    @IBOutlet weak var catsUserText: NSTextField!
    
    @IBOutlet weak var catsPasswordText: NSSecureTextField!
    
    @IBOutlet weak var catsConsumerKeyText: NSTextField!
    
    
    
    var appPreferenceManager: AppPreferenceManager!
    
    override init()
    {
        super.init()
    }
    
    override init(window: NSWindow!)
    {
        super.init(window: window)
    }
    
    required init?(coder: (NSCoder!))
    {
        super.init(coder: coder)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // populate preferences
        self.togglApiKeyText.stringValue = appPreferenceManager.appPreferences.togglApiKey
        self.catsServerText.stringValue = appPreferenceManager.appPreferences.catsServer
        self.catsUserText.stringValue = appPreferenceManager.appPreferences.catsUser
        self.catsPasswordText.stringValue = appPreferenceManager.appPreferences.catsPassword
        self.catsConsumerKeyText.stringValue = appPreferenceManager.appPreferences.catsConsumerKey
    }
    
   
    
    @IBAction func okButtonOnClick(sender: NSButton) {
        savePreferences()
    }
    
    func savePreferences() {
        appPreferenceManager.savePreferences(AppPreferences(togglApiKey: togglApiKeyText.stringValue,
            catsServer: catsServerText.stringValue, catsUser:catsUserText.stringValue, catsPassword: catsPasswordText.stringValue, catsConsumerKey: catsConsumerKeyText.stringValue))
        self.window!.orderOut(self)
    }
    
}
