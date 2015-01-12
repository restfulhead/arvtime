//
//  CATSClient.swift
//  arvtime
//
//  Created by patman on 1/11/15.
//  Copyright (c) 2015 arvato Systems. All rights reserved.
//

import Foundation
import XCGLogger
import Cocoa

struct UserDetails {
    var firstName : String
    var lastName : String
    var sid : String
    var defaultActivity : String
}

struct TimeEntryResult {
    var status: Int
    var timeId: String
}

class CATSClient {
    
    let log = XCGLogger.defaultInstance()
    
    let proto = "https://"
    let path = "/GUI4CATS/api/"
    let resource_users = "users"
    let resource_times = "times"
    
    let catsConsumerId = "CATSmobile-client"
    let catsVersion = "1.0"
    
    var appPreferenceManager: AppPreferenceManager
    
    
    init (appPreferenceManager: AppPreferenceManager) {
        self.appPreferenceManager = appPreferenceManager
    }
    
    // logs in the user with the given password. returns the user details or an error object
    func login(username: String, password: String, handler: (userDetails: UserDetails?, error: NSError?) -> Void) {
    
        let headerValues: [String : String] = ["User" : username, "Password" : password]
        
        var semaphore = dispatch_semaphore_create(0)
        var userDetails: UserDetails?
        var retSID: String?
        var retError: NSError?
        
        sendRequest(buildUrl(resource_users), method: "GET", headerValues: headerValues, requestData: nil, { (response:NSHTTPURLResponse?, json: JSON?, error: NSError?) -> Void in
            
            // populate SID and error
            if (json != nil)
            {
                let jsonData = json!
                
                userDetails = UserDetails(firstName: jsonData["prename"].string!, lastName: jsonData["name"].string!, sid: jsonData["meta"]["sid"].string!, defaultActivity: jsonData["defaultActivity"].string!)
                
                handler(userDetails: userDetails, error: error)
            }
            else
            {
                handler(userDetails: nil, error: error)
            }
        })
    }
    
    func postNewEntry(user: UserDetails, timeEntry: TimeEntry, orderId: String, subOrderId: String, handler: (result: TimeEntryResult?, error: NSError?) -> Void) {
        
        // construct request data
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyyMMdd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let date : String = dateStringFormatter.stringFromDate(timeEntry.date)
        
        let hours = String(timeEntry.duration)
        
        let requestData: [String : AnyObject] = ["date" : date, "workingHours" : hours, "comment" : timeEntry.description, "orderid" : orderId, "suborderid" : subOrderId, "activityid" : user.defaultActivity]
        
        let headerValues: [String : String] = ["sid" : user.sid]
        
        sendRequest(buildUrl(resource_times), method: "POST", headerValues: headerValues, requestData: requestData, { (response:NSHTTPURLResponse?, json: JSON?, error: NSError?) -> Void in
            
            // invoke response handler
            if (json != nil)
            {
                let jsonData = json!
                let httpStatus = jsonData["httpstatus"].int!
                let timeId = jsonData["timeId"].string!
                let result = TimeEntryResult(status: httpStatus, timeId: timeId)
                
                handler(result: result, error: error)
            }
            else {
                handler(result: nil, error: error)
            }
        })
    }
    
    
    func buildUrl(resource: String) -> String {
        return proto + appPreferenceManager.appPreferences.catsServer + path + resource
    }
    
    func sendRequest(url: String, method: String, headerValues: [String : String], requestData: [String : AnyObject]?, handler: (response:NSHTTPURLResponse?, data:JSON?, error:NSError?) -> Void) {
        
        // send request
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = method;
        
        // add standard header values
        request.setValue(catsConsumerId, forHTTPHeaderField: "Consumer-Id")
        request.setValue(appPreferenceManager.appPreferences.catsConsumerKey, forHTTPHeaderField: "Consumer-Key")
        request.setValue(catsVersion, forHTTPHeaderField: "Version")
        
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyyMMdd HH:mm:ss VV"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let timestamp = dateStringFormatter.stringFromDate(NSDate())
        request.setValue(timestamp, forHTTPHeaderField: "timestamp")
        
        // add request specific header values
        for (key, value) in headerValues {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // add request body
        if (requestData != nil)
        {
            var err: NSError?
            let payload = requestData! as Dictionary<String, AnyObject>
            let body = NSJSONSerialization.dataWithJSONObject(payload, options: nil, error: &err);
            if (err != nil) {
                handler(response: nil, data: nil, error: err)
            } else {
                request.HTTPBody = body!
                request.setValue(String(body!.length), forHTTPHeaderField: "Content-Length")
            }
        }

        if (log.isEnabledForLogLevel(XCGLogger.LogLevel.Debug)) {
            log.debug("Sending \(request.HTTPMethod) request to \(request.URL!) with headers \(request.allHTTPHeaderFields!)")
        }
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
            if let httpResponse = response as? NSHTTPURLResponse
            {
                if (jsonResult != nil) {
                    // process JSON result
                    if (httpResponse.statusCode < 200 || httpResponse.statusCode > 299)
                    {
                        // server error
                        let httpError = NSError(domain: self.appPreferenceManager.appPreferences.catsServer, code: httpResponse.statusCode, userInfo: ["NSLocalizedDescriptionKey" : "\(jsonResult)"])
                        
                        self.log.error("\(httpError)")
                        handler(response: httpResponse, data: nil, error: httpError)
                    } else {
                        // regular response with body
                        self.log.debug("\(jsonResult)")
                    
                        // par
                        let json = JSON(jsonResult!)
                        
                        handler(response: httpResponse, data: JSON(jsonResult!), error: nil)
                    }
                    
                } else if (error != nil) {
                    // application error
                    self.log.error("\(error)")
                    let nsError = error.memory
                    handler(response: httpResponse, data: nil, error: error.memory)
                } else {
                    let responseStatusMessage = NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode)
                    
                    if (httpResponse.statusCode < 200 || httpResponse.statusCode > 299)
                    {
                        // error response without response body
                         let httpError = NSError(domain: self.appPreferenceManager.appPreferences.catsServer, code: httpResponse.statusCode, userInfo: ["NSLocalizedDescriptionKey" : "\(responseStatusMessage)"])
                        
                        self.log.error("\(httpResponse.statusCode) \(responseStatusMessage)")
                        handler(response: httpResponse, data: nil, error: httpError)

                    }
                    else {
                        // regular response without response body
                        self.log.debug("Response \(httpResponse.statusCode) \(responseStatusMessage)")
                        handler(response: httpResponse, data: nil, error: nil)
                    }
                }

            } else {
                // assertion error
                let assertionError = NSError(domain: self.appPreferenceManager.appPreferences.catsServer, code: 40001, userInfo: ["NSLocalizedDescriptionKey" : "unexpected response type \(response)"])
                handler(response: nil, data: nil, error: assertionError)
            }
            
        })
    }
    
}