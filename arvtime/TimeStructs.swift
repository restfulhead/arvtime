//
//  TimeEntry.swift
//  arvtime
//
//  Created by patman on 1/10/15.
//  Copyright (c) 2015 arvato Systems. All rights reserved.
//

import Foundation

struct Project {
    var pid = ""
    var name = ""
}

struct Task {
    var tid = ""
    var name = ""
}

struct TimeEntry {
    
    var description = ""
    var duration = 0
    var date: NSDate
    
    var project: Project
    var task: Task
}
