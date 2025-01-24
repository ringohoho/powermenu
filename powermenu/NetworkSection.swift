//
//  NetworkSection.swift
//  powermenu
//
//  Created by RC on 24/1/25.
//

import SwiftUI

struct NetworkSection: View {
    @State
    private var chinaMainlanOk = false

    @State
    private var globalOk = false

    private let timer = Timer.publish(
        every: 5 /* seconds */, on: .main, in: .common
    ).autoconnect()

    var body: some View {
        VStack {
            Text("China Mainland: \(self.chinaMainlanOk ? "OK" : "Failed")")
            Text("Global: \(self.globalOk ? "OK" : "Failed")")
        }
        .task {
            self.checkNetworkConnection()
        }
        .onReceive(self.timer) { _ in
            self.checkNetworkConnection()
        }
    }

    private func checkNetworkConnection() {
        self.checkChinaMainland()
        self.checkGlobal()
    }

    private func checkChinaMainland() {
        let req = URLRequest(
            url: URL(
                string: "https://www.gov.cn/home/2016-05/11/content_5046257.htm"
            )!
        )
        let task = URLSession.shared.dataTask(with: req) {
            (data, resp, error) in
            var ok = false
            if let resp = resp as? HTTPURLResponse {
                if resp.statusCode >= 200 && resp.statusCode < 400 {
                    ok = true
                }
            }
            DispatchQueue.main.async {
                self.chinaMainlanOk = ok
            }
        }
        task.resume()
    }

    private func checkGlobal() {
        let req = URLRequest(
            url: URL(
                string: "https://www.google.com/"
            )!
        )
        let task = URLSession.shared.dataTask(with: req) {
            (data, resp, error) in
            var ok = false
            if let resp = resp as? HTTPURLResponse {
                if resp.statusCode >= 200 && resp.statusCode < 400 {
                    ok = true
                }
            }
            DispatchQueue.main.async {
                self.globalOk = ok
            }
        }
        task.resume()
    }
}
