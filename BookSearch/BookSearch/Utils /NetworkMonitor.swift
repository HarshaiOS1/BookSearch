//
//  NetworkMonitor.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 14/08/2024.
//

import Foundation
import Network
import Combine

/// A class responsible for monitoring the network connectivity status using `NWPathMonitor`.
///
/// The `NetworkMonitor` class observes changes in the device's network status and publishes
/// the connectivity state (`isConnected`) that other parts of the app can subscribe to.
///
/// - Note: The network status is updated on the main thread.
class NetworkMonitor: ObservableObject {
    private var monitor: NWPathMonitor
    private var cancellable: AnyCancellable?
    @Published var isConnected: Bool = true
    
    /// Initializes the `NetworkMonitor` and starts monitoring network connectivity.
    /// The monitoring is performed on a background queue and the results are dispatched
    /// on the main thread for UI updates.
    init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
}
