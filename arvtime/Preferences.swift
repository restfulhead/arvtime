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

    var catsServer: String
    var catsUser: String
    var catsPassword: String
    var catsConsumerKey: String
    
}

class AppPreferenceManager : NSObject {
    
    let log = XCGLogger.defaultInstance()
    
    var appPreferences = AppPreferences(togglApiKey: "", catsServer: "", catsUser: "", catsPassword: "", catsConsumerKey: "");
    
    override init() {
        super.init()
    }
    
    func savePreferences(preferences:AppPreferences) {
        log.info("Saving preferences")
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setObject(preferences.togglApiKey, forKey: "togglApiKey")
        defaults.setObject(preferences.catsServer, forKey: "catsServer")
        defaults.setObject(preferences.catsUser, forKey: "catsUser")
        defaults.setObject(preferences.catsPassword, forKey: "catsPassword")
        defaults.setObject(preferences.catsConsumerKey, forKey: "catsConsumerKey")
        
        defaults.synchronize()
        
        appPreferences = preferences
    }
    
    func loadPreferences() -> AppPreferences
    {
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        appPreferences = AppPreferences(togglApiKey: getOrDefault("togglApiKey", defaults: defaults),
            catsServer: getOrDefault("catsServer", defaults: defaults),
            catsUser: getOrDefault("catsUser", defaults: defaults),
            catsPassword: getOrDefault("catsPassword", defaults: defaults),
            catsConsumerKey: getOrDefault("catsConsumerKey", defaults: defaults))
        
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
