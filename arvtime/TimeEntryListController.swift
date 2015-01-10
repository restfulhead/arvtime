//
//  TimeEntryListController.swift
//  arvtime
//
//  Created by patman on 1/10/15.
//  Copyright (c) 2015 arvato Systems. All rights reserved.
//

import Foundation

import Cocoa
import XCGLogger

struct TimeEntryTableRow {
    var project = ""
    var task = ""
    var description = ""
}

class TimeEntryTableController : NSObject, NSTableViewDataSource,NSTableViewDelegate {
    
    
    let log = XCGLogger.defaultInstance()
    
    // data table logic
    func numberOfRowsInTableView(aTableView: NSTableView!) -> Int
    {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        return appDelegate.timeEntryList.count
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject!
    {
        let row = getValues()[row];
        return row.objectForKey(tableColumn.identifier);
    }
    
    func getDataArray() -> NSArray{
        var dataArray:[NSDictionary] = [["FirstName": "Debasis", "LastName": "Das"],
            ["FirstName": "Nishant", "LastName": "Singh"],
            ["FirstName": "John", "LastName": "Doe"],
            ["FirstName": "Jane", "LastName": "Doe"],
            ["FirstName": "Mary", "LastName": "Jane"]];
        return dataArray;
    }

    func getValues() -> [NSDictionary] {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        
        var rows:[NSDictionary] = []

        for timeEntry in appDelegate.timeEntryList {
            let row:NSDictionary = ["project" : timeEntry.project.name, "task": timeEntry.task.name, "description": timeEntry.description];
            rows.append(row);
        }
        
        return rows
    }
    
    
}