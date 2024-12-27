//
//  DropTextView.swift
//  TestOpenAlias
//
//  Created by Heinz-Jörg on 26.12.24.
//

import AppKit
import UniformTypeIdentifiers

class DropTextView: NSTextView {
    

    override func awakeFromNib() {
        registerForDraggedTypes([.fileURL
                                 , .tabularText
                                 , .fileContents
                                 , .html
                                 , .multipleTextSelection
                                 , .rtf
                                 , .rtfd
                                 , .string
                                ])
    }
    

    /// Displays an error.
    private func handleError(_ error: Error) {
        print(error)
    }
    


    /// Copies contents of the file to self.string to display it.
    /// - Parameter fileEncoding: character encoding used to try decoding
    /// - Parameter showAlert: if YES shows alert
    /// - Returns: true if new file was opened successfully
    fileprivate func openFileWithEncoding(url: URL, _ fileEncoding: String.Encoding) -> Bool {
        var opened = false

        do {
            textStorage?.setAttributedString(NSAttributedString(string: ""))
            string = try String(contentsOf: url, encoding: fileEncoding)
            opened = true
        }
        catch {
            let alert = NSAlert()
            
            alert.alertStyle = .informational
            alert.messageText = String(localized: "Opening failed")
            alert.informativeText = error.localizedDescription
            + String(localized:
                    """
                    
                    
                    Please drop the original file and then
                    try again to drop the alias.
                    """
            )
            alert.addButton(withTitle: String(localized: "Close"))
            alert.runModal()
        }
        return opened
    }
    
    /// Open file given by url and resolves eventually given alias.
    /// - Parameter url: Local file url
    ///
    /// As written in the documentation 'URL(resolvingAliasFileAt: )' does not respect the security scope. Therefore
    /// I tried to resolve the bookmark data beforehand. But this does not help.
    private func openUsingBookmark(url: URL) {
        do {
            var isStale = false
            let bookmarkUrl = try URL(resolvingBookmarkData: url.bookmarkData(), bookmarkDataIsStale: &isStale)
            let resolved = try URL(resolvingAliasFileAt: bookmarkUrl, options: [])
            _ = self.openFileWithEncoding(url: resolved, .utf8)
        }
        catch {
            
        }

    }

    
    /// Updates the canvas with a given image file.
    private func handleFile(at url: URL) {
        print(url.path())
        OperationQueue.main.addOperation {
            self.openUsingBookmark(url: url)
            /*
            if let resolved = try? URL(resolvingAliasFileAt: url, options: []) {
                Logger.write("Resolving alias")
                _ = self.openFileWithEncoding(url: resolved, .utf8)
            }
             */
        }
    }

    
    /// Queue used for reading and writing file promises.
    private lazy var workQueue: OperationQueue = {
        let providerQueue = OperationQueue()
        providerQueue.qualityOfService = .userInitiated
        return providerQueue
    }()

    
    /// Directory URL used for accepting file promises.
    private lazy var destinationURL: URL = {
        let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Drops")
        try? FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
        return destinationURL
    }()



    @MainActor override
    // MARK: - NSDraggingSource
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return (context == .outsideApplication) ? [.copy] : []
    }
    
    // MARK: - NSDraggingDestination
    
    @MainActor override
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return sender.draggingSourceOperationMask.intersection([.copy])
    }

    
    @MainActor override
    func performDragOperation(_ sender: any NSDraggingInfo) -> Bool {
        print("")
        let result = true
        
        let supportedClasses = [
            NSFilePromiseReceiver.self,
            NSURL.self
        ]

        // Look for possible URLs we can consume (image URLs).
        var acceptedTypes: [String]
        if #available(macOS 11.0, *) {
            acceptedTypes = [UTType.item.identifier
                             , UTType.text.identifier
                            ]
        } else {
            acceptedTypes = [kUTTypeItem as String]
        }
        
        let searchOptions: [NSPasteboard.ReadingOptionKey: Any] = [
            .urlReadingFileURLsOnly: false,
            .urlReadingContentsConformToTypes: acceptedTypes
        ]
        /// - Tag: HandleFilePromises
        sender.enumerateDraggingItems(options: [], for: nil, classes: supportedClasses, searchOptions: searchOptions) {
            (draggingItem, idx, stop) in
            print(draggingItem.item)
            switch draggingItem.item {
            case let filePromiseReceiver as NSFilePromiseReceiver:
                filePromiseReceiver.receivePromisedFiles(atDestination: self.destinationURL, options: [:],
                                                         operationQueue: self.workQueue) { (fileURL, error) in
                    if let error = error {
                        self.handleError(error)
                    } else {
                        self.handleFile(at: fileURL)
                    }
                }
            case let fileURL as URL:
                self.handleFile(at: fileURL)
            default:
                break
            }
        }
        

        return result
    }

    
}

