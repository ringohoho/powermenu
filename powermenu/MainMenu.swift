//
//  MainMenu.swift
//  powermenu
//
//  Created by RC on 13/1/25.
//

import SwiftUI

struct MainMenu: View {
    @State private var mountedVolumes: [(name: String, url: URL)] = []

    var body: some View {
        VStack {
            Section("Disk") {
                DiskSection()
            }
        }
    }
}

#Preview {
    Menu("PowerMenu") {
        MainMenu()
    }
    .menuIndicator(.hidden)
    .fixedSize()
}
