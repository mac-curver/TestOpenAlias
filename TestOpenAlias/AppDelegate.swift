//
//  AppDelegate.swift
//  TestOpenAlias
//
//  Created by Heinz-Jörg on 26.12.24.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet var window: NSWindow!


	func applicationDidFinishLaunching(_ aNotification: Notification) {
		let alert = NSAlert()
		
		alert.alertStyle = .critical
		alert.messageText = String(localized: "MessageText")
		alert.informativeText = String(
			localized: "DidFinishLaunching"
			, defaultValue: """
					Could be multiline text.
					"""
			, comment: "Multiline text"
		)
		alert.addButton(withTitle: "Quit")
		alert.runModal()
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}


}

