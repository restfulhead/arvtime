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
    
    var progressIndicator: NSProgressIndicator!
    var progressStatusLine: NSTextField!
    
    init(progressIndicator: NSProgressIndicator, progressStatusLine: NSTextField) {
        self.progressIndicator = progressIndicator
        self.progressStatusLine = progressStatusLine
    }
    
    func startProgress(status:String) {
        progressIndicator.startAnimation(self)
        progressStatusLine.stringValue = status
    }
    
    func updateProgress(status:String) {
        progressStatusLine.stringValue = status
    }

    func stopProgress(status: String) {
        progressIndicator.stopAnimation(self)
        progressStatusLine.stringValue = status
    }
    
}