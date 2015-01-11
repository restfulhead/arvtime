//
//  Preferences.swift
//  arvtime
//
//  Created by patman on 1/11/15.
//  Copyright (c) 2015 arvato Systems. All rights reserved.
//

import Foundation
import XCGLogger

struct AppPreferences
{
    var togglApiKey: String
    
    
}

class AppPreferenceManager : NSObject {
    
    let log = XCGLogger.defaultInstance()
    
    var appPreferences = AppPreferences(togglApiKey:"")
    
    override init() {
        super.init()
    }
    
    func savePreferences(preferences:AppPreferences) {
        log.info("Saving preferences")
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setObject(preferences.togglApiKey, forKey: "togglApiKey")
        
        defaults.synchronize()
        
        appPreferences = preferences
    }
    
    func loadPreferences() -> AppPreferences
    {
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        appPreferences = AppPreferences(togglApiKey: getOrDefault("togglApiKey", defaults: defaults))
        
        return appPreferences
    }

    func getOrDefault(key: String, defaults: NSUserDefaults) -> String {
        
        if let value = defaults.objectForKey(key) as? String {
            return value;
        } else {
            return "";
        }
    }
    
}
