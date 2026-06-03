import Foundation
@testable import Dagify

class MockNetworkMonitor: NetworkMonitorProtocol {
    var isConnected: Bool = true
}
