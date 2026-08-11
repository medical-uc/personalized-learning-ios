//
//  Reachability.swift
//  personalized-medical-learning-ios
//

import Foundation
import Network

/// App-wide network reachability, backed by NWPathMonitor. Read `isOnline` before
/// firing a request to fail fast with a clear message instead of waiting out a
/// system-level timeout; observe `.networkStatusChanged` to drive an offline banner.
@MainActor
final class Reachability {
    static let shared = Reachability()

    private(set) var isOnline = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Reachability.monitor")

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let online = path.status == .satisfied
            Task { @MainActor in
                self?.updateStatus(online: online)
            }
        }
        monitor.start(queue: queue)
    }

    private func updateStatus(online: Bool) {
        guard online != isOnline else { return }
        isOnline = online
        NotificationCenter.default.post(name: .networkStatusChanged, object: nil, userInfo: [Reachability.isOnlineKey: online])
    }

    static let isOnlineKey = "isOnline"
}

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}
