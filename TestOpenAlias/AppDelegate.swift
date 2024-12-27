//
//  AppDelegate.swift
//  TestOpenAlias
//
//  Created by LegoEsprit on 26.12.24.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet var window: NSWindow!


	func applicationDidFinishLaunching(_ aNotification: Notification) {
		let alert = NSAlert()
		
        alert.alertStyle = .informational
		alert.messageText = String(localized: "Shows wrong alias access")
		alert.informativeText = String(
			localized: "DidFinishLaunching"
			, defaultValue:
                """
                This small application shows, that alias resolving fails in sandbox.
                When draging and drop an alias for the first time we receive an
                access not granted error. After having opened the original file once,
                resolving the alias works.
                """
			, comment: "Multiline text"
		)
		alert.addButton(withTitle: "Show")
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

