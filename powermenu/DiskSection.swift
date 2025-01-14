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

    var shortDescription: String {
        if self.isReadOnly {
            return self.name
        } else {
            let used = ByteCountFormatter.string(
                fromByteCount: self.capacityBytes - self.availableBytes,
                countStyle: .file)
            let avail = ByteCountFormatter.string(
                fromByteCount: self.availableBytes, countStyle: .file)
            return "\(self.name): \(used) used, \(avail) free"
        }
    }
}

struct DiskSection: View {
    @State
    private var volumes: [Volume] = []

    var body: some View {
        VStack {
            ForEach(self.volumes, id: \.url) { vol in
                Button(vol.shortDescription) {}
            }
        }
        .task {
            self.startBackgroundTask()
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
}
