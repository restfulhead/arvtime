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

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!
    
    let log = XCGLogger.defaultInstance()
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    let timeEntryImporter = TimerEntryImporter()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // initialize logging
        log.setup(logLevel: .Debug, showLogLevel: true, showFileNames: true, showLineNumbers: true)
        
        // initialize icon
        let icon = NSImage(named: "statusIcon")
        icon?.setTemplate(true)
        
        // initialize status menu
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        // hide main window
        self.window!.orderOut(self)
        
        // start tasks
        //timeEntryImporter.start()
        timeEntryImporter.importTimeEntries();
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        
        // stop tasks
        //timeEntryImporter.stop();
    }


    @IBAction func menueClicked(sender: NSMenuItem) {
        log.info("Window is visible: \(self.window!.visible)")

        if (self.window!.visible) {
            self.window!.orderOut(self)
            sender.title = "Show time entries"
        } else {
            self.window!.orderFront(self)
            sender.title = "Hide time entries"
        }
        
    }
}

