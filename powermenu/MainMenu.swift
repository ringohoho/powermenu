//
//  MainMenu.swift
//  powermenu
//
//  Created by RC on 13/1/25.
//

import SwiftUI

struct MainMenu: View {
    var body: some View {
        VStack {
            Button("First") {

            }
            Button("Second") {

            }
            Divider()
            Button("Third") {

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
