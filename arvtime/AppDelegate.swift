//
//  AppDelegate.swift
//  arvtime
//
//  Created by patman on 1/10/15.
//  Copyright (c) 2015 arvato Systems. All rights reserved.
//

import Cocoa
import XCGLogger

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // UI
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var timeEntryTable: NSTableView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var progressStatusLine: NSTextField!
    
    var preferencesWindow: PreferencesController!
    var progressController: ProgressController!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    // business logic
    let log = XCGLogger.defaultInstance()
    var timeEntryList: [TimeEntry] = []
    var appPreferenceManager: AppPreferenceManager!
    var timeEntryImporter: TimerEntryImporter!
    var catsClient : CATSClient!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // initialize logging
        log.setup(logLevel: .Debug, showLogLevel: true, showFileNames: true, showLineNumbers: true)

        // hide main window
        //self.window!.orderOut(self)

        // load user preferences
        appPreferenceManager = AppPreferenceManager()
        appPreferenceManager.loadPreferences()
        timeEntryImporter = TimerEntryImporter(appPreferenceManager: appPreferenceManager)
        catsClient = CATSClient(appPreferenceManager: appPreferenceManager)
        
        // initialize icon
        let icon = NSImage(named: "statusIcon")
        icon?.setTemplate(true)
        
        // initialize status menu
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        // initialize other controls
        progressController = ProgressController(progressIndicator: progressIndicator, progressStatusLine: progressStatusLine)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        

    }

    // status menu logic
    @IBAction func statusMenuOnClick(sender: NSMenuItem) {
        log.info("Window is visible: \(self.window!.visible)")

        if (self.window!.visible) {
            self.window!.orderOut(self)
            sender.title = "Show time entries"
        } else {
            self.window!.orderFront(self)
            sender.title = "Hide time entries"
        }
    }
    
    // preferences menu
    @IBAction func menuPreferencesOnClick(sender: NSMenuItem) {
        if(preferencesWindow == nil) {
            preferencesWindow = PreferencesController(windowNibName:"Preferences")
            preferencesWindow.appPreferenceManager = appPreferenceManager;
        }
        
        preferencesWindow.showWindow(self)
    }
    
    @IBAction func importButtonOnClick(sender: NSButton) {
        importTimeEntries()
    }
    
    @IBAction func exportButtonOnClick(sender: NSButton) {
        exportTimeEntries()
    }
    
    
    
    func importTimeEntries()
    {
        progressController.startProgress("Importing time entries from Toggl")
        
        timeEntryList.removeAll(keepCapacity: true)
        timeEntryImporter.importTimeEntries({ (timeEntries: [TimeEntry]) -> Void in
            
            var count = 0
            for timeEntry in timeEntries {
                self.timeEntryList.append(timeEntry)
                count++
            }
            
            // refresh data table
            self.timeEntryTable.reloadData()
            
            // stop progress
            self.progressController.stopProgress("Successfully loaded \(count) entries")
            
            // refresh display
            self.window.display()
        })
    }
    
    func exportTimeEntries()
    {
        // do nothing if we don't have any time entries
        if (timeEntryList.count < 1) {
            return; // nothing to do
        }
        
        // get selected time entries
        let selectedRows = timeEntryTable.selectedRowIndexes
        if (selectedRows.count < 1) {
            return; // nothing selected
        }
        
        var selectedTimeEntries : [TimeEntry] = []
        var index = selectedRows.firstIndex
        while (index != NSNotFound) {
            selectedTimeEntries.append(timeEntryList[index])
            index = selectedRows.indexGreaterThanIndex(index)
        }
        
        progressController.startProgress("Exporting \(selectedTimeEntries.count) time entries to CATS")
        self.window.display()
        
        // (1) first log in to get a session id
        var semaphore = dispatch_semaphore_create(0)
        var retUserDetails: UserDetails?
        
        catsClient.login(appPreferenceManager.appPreferences.catsUser, password: appPreferenceManager.appPreferences.catsPassword, handler: {(userDetails: UserDetails?, error: NSError?) -> Void in
            
            self.progressController.updateProgress("Authenticated as \(userDetails!.firstName) \(userDetails!.lastName), now posting time entries...")
            retUserDetails = userDetails;
            
            // signal that we've processed the response and we're done waiting
            dispatch_semaphore_signal(semaphore)
        })

        // wait for the async web service call to finish
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        // refresh display
        self.window.display()
        
        // (2) post each selected entry
        var count = 0
        var total = selectedTimeEntries.count
        for timeEntry in selectedTimeEntries {
            
            // FIXME get order id and sub order id from time entry project configuration
            catsClient.postNewEntry(retUserDetails!, timeEntry: timeEntry, orderId: "USI00028", subOrderId: "USI00028-110", handler: {(result:TimeEntryResult?, error:NSError?) -> Void in
              
                self.progressController.updateProgress("Successfully created \(result!.timeId)")
                
                count++
            })
        }
        
        while (count < total) {
            // wait until all entries where posted
        }
        
        progressController.stopProgress("Successfully exported \(count) entries")
        
        // refresh display
        self.window.display()
    }
}
