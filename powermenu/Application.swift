//
//  Application.swift
//  powermenu
//
//  Created by RC on 13/1/25.
//

import SwiftUI

@main
struct Application: App {
    @State private var command: String = "a"

    var body: some Scene {
        MenuBarExtra {
            MainMenu()
            Divider()
            Button("Quit") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("Q")
        } label: {
            let image: NSImage = {
                let ratio = $0.size.height / $0.size.width
                $0.size.height = 18
                $0.size.width = 18 / ratio
                return $0
            }(NSImage(named: "control")!)
            Image(nsImage: image)
        }
        .menuBarExtraStyle(.menu)
    }
}
