//
//  arvtimeTests.swift
//  arvtimeTests
//
//  Created by patman on 1/10/15.
//  Copyright (c) 2015 arvato Systems. All rights reserved.
//

import Cocoa
import XCTest
import arvtime
import XCGLogger

class catsClientTests: XCTestCase {
    
    let log = XCGLogger.defaultInstance()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLogin()
    {
        // setup client based on user preferences
        let appPreferenceManager = AppPreferenceManager()
        appPreferenceManager.loadPreferences()
        let client = CATSClient(appPreferenceManager: appPreferenceManager)

        // call web service
        var semaphore = dispatch_semaphore_create(0)
        var retError: NSError?
        var retUserDetails: UserDetails?
        
        client.login(appPreferenceManager.appPreferences.catsUser, password: appPreferenceManager.appPreferences.catsPassword, handler: {(userDetails: UserDetails?, error: NSError?) -> Void in
        
            self.log.info("Log in successful, session id \(userDetails!.sid)")
            retError = error;
            retUserDetails = userDetails;
            
            // signal that we've processed the response and we're done waiting
            dispatch_semaphore_signal(semaphore)
        })
        
        // wait for the async web service call to finish
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        // check result
        XCTAssertNil(retError)
        XCTAssert(countElements(retUserDetails!.sid) > 5)
        XCTAssert(countElements(retUserDetails!.defaultActivity) > 1)
    }
    
    func testPost() {
        // setup client based on user preferences
        let appPreferenceManager = AppPreferenceManager()
        appPreferenceManager.loadPreferences()
        let client = CATSClient(appPreferenceManager: appPreferenceManager)

        let sid = "INSERT YOUR SID HERE"
        let defaultActivity = "U1050"
        
        let userDetails = UserDetails(firstName: "Patrick", lastName: "Ruhkopf", sid: sid, defaultActivity: defaultActivity)
        let project = Project(pid: "123", name: "Test project")
        let task = Task(tid: "456", name: "test task")
        let date = NSDate()
        
        let timeEntry = TimeEntry(description: "Unit test \(date)", duration: 1, date: date, project: project, task: task)
        
        var semaphore = dispatch_semaphore_create(0)
        var newEntryId : String?;
        
        client.postNewEntry(userDetails, timeEntry: timeEntry, orderId: "USI00028", subOrderId: "USI00028-110", handler: { (result: TimeEntryResult?, error: NSError?) -> Void in
           
            self.log.info("Time entry \(result!.timeId) created with result \(result!.status)")
            newEntryId = result!.timeId
            
            // signal that we've processed the response and we're done waiting
            dispatch_semaphore_signal(semaphore)
        })
        
        // wait for the async web service call to finish
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        XCTAssertNotNil(newEntryId)
        XCTAssert(countElements(newEntryId!) > 1)
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    
}
