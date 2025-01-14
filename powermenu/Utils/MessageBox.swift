//
//  MesssageBox.swift
//  powermenu
//
//  Created by RC on 15/1/25.
//

import SwiftUI

struct MessageBox {
    static func error(_ message: String) {
        DispatchQueue.main.async {
            let alert: NSAlert = NSAlert()
            alert.messageText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}
