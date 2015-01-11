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

class catsClientTests: XCTestCase {
    
    let client = CATSClient()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLogin() {
        let response  = client.login("INSERT USER", password: "INSERTPASSWORD")
        XCTAssertNotNil(response.sid)
        XCTAssertNil(response.error)
        XCTAssert(countElements(response.sid!) > 5)
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    
}
