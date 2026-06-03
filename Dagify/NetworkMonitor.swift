//
//  NetworkMonitor.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation
import Network
import Observation

// MARK: - Protocol Definition
protocol NetworkMonitorProtocol {
    var isConnected: Bool { get }
}

// MARK: - Service Implementation
@Observable
class NetworkMonitor: NetworkMonitorProtocol {

    // MARK: - Properties
    var isConnected: Bool = true
     let monitor = NWPathMonitor()
     let queue = DispatchQueue(label: "NetworkMonitor")

    // MARK: - Initialization
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
