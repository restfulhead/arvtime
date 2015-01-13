//
//  ProgressController.swift
//  arvtime
//
//  Created by patman on 1/11/15.
//  Copyright (c) 2015 arvato Systems. All rights reserved.
//

import Foundation
import XCGLogger
import Cocoa

class ProgressController {
    
    let log = XCGLogger.defaultInstance()
    
    var progressIndicator: NSProgressIndicator!
    var progressStatusLine: NSTextField!
    
    init(progressIndicator: NSProgressIndicator, progressStatusLine: NSTextField) {
        self.progressIndicator = progressIndicator
        self.progressStatusLine = progressStatusLine
        self.progressIndicator.hidden = true;
    }
    
    func startProgress(status:String) {
        progressIndicator.startAnimation(self)
        progressStatusLine.stringValue = status
        self.progressIndicator.hidden = false;
        log.debug(status)
    }
    
    func updateProgress(status:String) {
        progressStatusLine.stringValue = progressStatusLine.stringValue + "\n" + status
        log.debug(status)
    }

    func stopProgress(status: String) {
        progressIndicator.stopAnimation(self)
        progressStatusLine.stringValue = progressStatusLine.stringValue + "\n" + status
        self.progressIndicator.hidden = true;
        log.debug(status)
    }
    
}