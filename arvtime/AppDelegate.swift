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
    var preferencesWindow: PreferencesController!
    
    // TODO move me
    @IBOutlet weak var timeEntryTable: NSTableView!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    // business logic
    let log = XCGLogger.defaultInstance()
    var timeEntryList: [TimeEntry] = []
    var appPreferenceManager: AppPreferenceManager!
    var timeEntryImporter: TimerEntryImporter!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // initialize logging
        log.setup(logLevel: .Debug, showLogLevel: true, showFileNames: true, showLineNumbers: true)
        
        // load user preferences
        appPreferenceManager = AppPreferenceManager()
        appPreferenceManager.loadPreferences()
        timeEntryImporter = TimerEntryImporter(appPreferenceManager: appPreferenceManager)
        
        // initialize icon
        let icon = NSImage(named: "statusIcon")
        icon?.setTemplate(true)
        
        // initialize status menu
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        // hide main window
        //self.window!.orderOut(self)
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        
        // stop tasks
        //timeEntryImporter.stop();
    }


    func importTimeEntries()
    {
        timeEntryImporter.importTimeEntries({ (timeEntry: TimeEntry) -> Void in
            self.timeEntryList.append(timeEntry)
            self.timeEntryTable.reloadData()
            self.window.display()
        })
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
    }
    
    
   }

