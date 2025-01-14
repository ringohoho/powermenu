//
//  DirectoryMonitor.swift
//  powermenu
//
//  Created by RC on 14/1/25.
//

import Foundation

class DirectoryMonitor {
    private let fd: CInt
    private let source: DispatchSourceProtocol

    deinit {
        self.source.cancel()
        close(self.fd)
    }

    init(
        url: URL, eventMask: DispatchSource.FileSystemEvent,
        handler: @escaping () -> Void
    ) {
        self.fd = open((url as NSURL).fileSystemRepresentation, O_EVTONLY)
        self.source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: self.fd,
            eventMask: eventMask,
            queue: DispatchQueue.global(qos: .utility))
        self.source.setEventHandler {
            handler()
        }
        self.source.resume()
    }
}
