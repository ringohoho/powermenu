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

            Menu {
                if self.mountedVolumes.isEmpty {
                    Text("Empty")
                } else {
                    ForEach(self.mountedVolumes, id: \.url) { volume in
                        Button(volume.name) {
                            self.ejectVolume(volume)
                        }
                    }
                }
            } label: {
                Text("Eject")
            }
            .onAppear {
                self.refreshMountedVolumes()
            }
        }
    }

    private func refreshMountedVolumes() {
        DispatchQueue.global(qos: .utility).async {
            let resKeys: [URLResourceKey] = [
                .isVolumeKey,
                .volumeNameKey,
                .volumeLocalizedNameKey,
                .volumeIsEjectableKey,
                .volumeIsRemovableKey,
                .volumeTotalCapacityKey,
                .volumeAvailableCapacityKey,
            ]
            let resKeySet = Set(resKeys)

            var volumes: [(name: String, url: URL)] = []

            if let paths = FileManager.default.mountedVolumeURLs(
                includingResourceValuesForKeys: resKeys,
                options: [.skipHiddenVolumes])
            {
                //                print("paths: \(paths)")
                for path in paths {
                    let res = try? path.resourceValues(
                        forKeys: resKeySet)
                    if let isVolume = res?.isVolume, !isVolume {
                        continue
                    }
                    if let isEjectable = res?.volumeIsEjectable,
                        !isEjectable
                    {
                        continue
                    }
                    if let isRemovable = res?.volumeIsRemovable, !isRemovable {
                        continue
                    }
                    if let volumnName = res?.volumeLocalizedName {
                        volumes.append((name: volumnName, url: path))
                    }
                }
            }

            print("mounted volumes: \(volumes)")
            self.mountedVolumes = volumes
        }
    }

    private func ejectVolume(_ volume: (name: String, url: URL)) {
        print("ejecting \"\(volume.name)\"")
        DispatchQueue.global(qos: .utility).async {
            do {
                try NSWorkspace.shared.unmountAndEjectDevice(at: volume.url)
            } catch let err {
                self.error("Failed to eject \(volume.name). Error: \(err)")
            }
            self.refreshMountedVolumes()
        }
    }

    private func error(_ message: String) {
        DispatchQueue.main.async {
            let alert: NSAlert = NSAlert()
            alert.messageText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
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
