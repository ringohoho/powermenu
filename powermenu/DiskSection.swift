//
//  DiskSection.swift
//  powermenu
//
//  Created by RC on 14/1/25.
//

import SwiftUI

private struct Volume {
    var url: URL
    var name: String
    var capacityBytes: Int64
    var availableBytes: Int64
    var isEjectable: Bool
    var isReadOnly: Bool  // don't need to show capacity for read only volumes

    var usedBytes: Int64 {
        self.capacityBytes - self.availableBytes
    }

    var capacityText: String {
        ByteCountFormatter.string(
            fromByteCount: self.capacityBytes, countStyle: .file)
    }

    var usedText: String {
        ByteCountFormatter.string(
            fromByteCount: self.usedBytes,
            countStyle: .file)
    }

    var availText: String {
        ByteCountFormatter.string(
            fromByteCount: self.availableBytes, countStyle: .file)
    }

    var percent: Double {
        if self.isReadOnly {
            return 100
        } else {
            return Double(self.usedBytes) / Double(self.capacityBytes) * 100
        }
    }
}

struct DiskSection: View {
    @State
    private var volumes: [Volume] = []

    private let timer = Timer.publish(
        every: 10 /* seconds */, on: .main, in: .common
    ).autoconnect()

    var body: some View {
        VStack {
            ForEach(self.volumes, id: \.url) { vol in
                let percent =
                    vol.isReadOnly
                    ? "readonly" : "\(Int(vol.percent.rounded()))%"
                Menu("\(vol.name): \(percent)") {
                    if !vol.isReadOnly {
                        Text("Total: \(vol.capacityText)")
                        Text("Free: \(vol.availText)")
                    }
                    if vol.isEjectable {
                        Button("Eject") {
                            self.ejectVolume(vol)
                        }
                    }
                }
            }
        }
        .task {
            self.startBackgroundTask()
        }
        .onReceive(self.timer) { _ in
            DispatchQueue.global(qos: .utility).async {
                self.refreshVolumes()
            }
        }
    }

    @State
    private var monitor: DirectoryMonitor? = nil

    private func startBackgroundTask() {
        DispatchQueue.global(qos: .utility).async {
            self.refreshVolumes()
            self.monitor = DirectoryMonitor(
                url: URL(filePath: "/Volumes")!, eventMask: .all
            ) {
                self.refreshVolumes()
            }
        }
    }

    private func refreshVolumes() {
        let resKeys: [URLResourceKey] = [
            .volumeNameKey,
            .volumeLocalizedNameKey,
            .volumeIsRootFileSystemKey,
            .volumeIsEjectableKey,
            .volumeIsRemovableKey,
            .volumeIsInternalKey,
            .volumeIsReadOnlyKey,
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey,
        ]
        let resKeySet = Set(resKeys)

        var volumes: [Volume] = []
        if let urls = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: resKeys,
            options: [.skipHiddenVolumes])
        {
            for url in urls {
                guard let res = try? url.resourceValues(forKeys: resKeySet)
                else {
                    continue
                }

                if !(res.volumeIsRootFileSystem!
                    || (url.pathComponents.count == 3
                        && url.pathComponents[0] == "/"
                        && url.pathComponents[1] == "Volumes"))
                {
                    // ignore volumes that are not mounted in to `/Volumes`
                    continue
                }

                volumes.append(
                    Volume(
                        url: url, name: res.volumeLocalizedName!,
                        capacityBytes: Int64(res.volumeTotalCapacity!),
                        availableBytes: max(
                            res.volumeAvailableCapacityForImportantUsage!,
                            Int64(res.volumeAvailableCapacity!)),
                        isEjectable: res.volumeIsEjectable!,
                        isReadOnly: res.volumeIsReadOnly!
                    )
                )
            }
        }
        self.volumes = volumes
    }

    private func ejectVolume(_ volume: Volume) {
        print("ejecting \"\(volume.name)\"")
        DispatchQueue.global(qos: .utility).async {
            do {
                try NSWorkspace.shared.unmountAndEjectDevice(at: volume.url)
            } catch let err {
                MessageBox.error(
                    "Failed to eject \(volume.name). Error: \(err)")
            }
        }
    }
}
