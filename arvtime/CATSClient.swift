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

class CATSClient {
    
    let log = XCGLogger.defaultInstance()
    
    let proto = "https://"
    let server = "cats.arvato-systems.de"
    let path = "/GUI4CATS/api/"
    let resource_users = "users"
    
    let catsConsumerId = "CATSmobile-client"
    let catsConsumerKey = "C736938F-02FC-4804-ACFE-00E20E21D198"
    let catsVersion = "1.0"
    
    // logs in the user with the given password. returns the session id or an error object
    func login(username: String, password: String) -> (sid: String?, error: NSError?) {
    
        let headerValues: [String : String] = ["User" : username, "Password" : password]
        
        // we want to wait for the response
        var semaphore = dispatch_semaphore_create(0)
        var retSID: String?
        var retError: NSError?
        
        sendRequest(buildUrl(resource_users), headerValues: headerValues, { (response:NSHTTPURLResponse, json: JSON?, error: NSError?) -> Void in
            
            // populate SID and error
            if (json != nil)
            {
                let jssonData = json!
                retSID = jssonData["meta"]["sid"].string
            }
            
            retError = error
            
            dispatch_semaphore_signal(semaphore)
        })
        
        // wait for response
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return (sid: retSID, error: retError)
    }
    
    func buildUrl(resource: String) -> String {
        return proto + server + path + resource
    }
    
    func sendRequest(url: String, headerValues: [String : String], handler: (response:NSHTTPURLResponse, data:JSON?, error:NSError?) -> Void) {
        
        // send GET request
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        
        // add standard header values
        request.setValue(catsConsumerId, forHTTPHeaderField: "Consumer-Id")
        request.setValue(catsConsumerKey, forHTTPHeaderField: "Consumer-Key")
        request.setValue(catsVersion, forHTTPHeaderField: "Version")
        
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyyMMdd HH:mm:ss VV"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let timestamp = dateStringFormatter.stringFromDate(NSDate())
        request.setValue(timestamp, forHTTPHeaderField: "timestamp")
        
        // add request specific header values
        for (key, value) in headerValues {
            request.setValue(value, forHTTPHeaderField: key)
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
                        let httpError = NSError(domain: self.server, code: httpResponse.statusCode, userInfo: ["NSLocalizedDescriptionKey" : "\(jsonResult)"])
                        
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
                    
                    // regular response without response body
                    let responseStatusMessage = NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode)
                    self.log.debug("Response \(httpResponse.statusCode) \(responseStatusMessage)")
                    handler(response: httpResponse, data: nil, error: nil)
                }

            } else {
                assertionFailure("unexpected response type \(response)")
            }
            
        })
    }
    
}