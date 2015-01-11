//
//  PreferencesController.swift
//  arvtime
//
//  Created by patman on 1/11/15.
//  Copyright (c) 2015 arvato Systems. All rights reserved.
//

import Foundation
import Cocoa
import XCGLogger

class PreferencesController : NSWindowController {
    
    let log = XCGLogger.defaultInstance()
    
    @IBOutlet weak var togglApiKeyText: NSTextField!
    
    var appPreferenceManager: AppPreferenceManager!
    
    override init()
    {
        super.init()
        log.info("init()")
    }
    
    override init(window: NSWindow!)
    {
        super.init(window: window)
    }
    
    required init?(coder: (NSCoder!))
    {
        super.init(coder: coder)
        log.info("init(NScoder)")

    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // populate preferences
        self.togglApiKeyText.stringValue = appPreferenceManager.appPreferences.togglApiKey
    }
    
   
    
    @IBAction func okButtonOnClick(sender: NSButton) {
        savePreferences()
    }
    
    func savePreferences() {
        appPreferenceManager.savePreferences(AppPreferences(togglApiKey: togglApiKeyText.stringValue))
        self.window!.orderOut(self)
    }
    
}
