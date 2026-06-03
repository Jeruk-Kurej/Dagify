import Foundation
import Observation

struct TrafficData: Identifiable {
    let id = UUID()
    let label: String
    let count: Int
}

// ✅ ENUM UNTUK IDENTIFIKASI SHEET
enum CRMSheetType: Identifiable {
    case total
    case loyal
    var id: String {
        switch self {
        case .total: return "total"
        case .loyal: return "loyal"
        }
    }
}

@MainActor
@Observable
class CRMViewModel {
    var customers: [Customer] = []
    var storeBranches: [Branch] = [] // ✅ List cabang dari Toko ini
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    var loyalCustomers: [Customer] { customers.filter { $0.isLoyal } }
    
    var peakHoursData: [TrafficData] {
        var counts = [Int: Int]()
        let calendar = Calendar.current
        for customer in customers {
            for visit in customer.visitHistory {
                let hour = calendar.component(.hour, from: visit)
                counts[hour, default: 0] += 1
            }
        }
        return counts.keys.sorted().map { TrafficData(label: String(format: "%02d:00", $0), count: counts[$0]!) }
    }
    
    private let crmProtocol: CRMProtocol
    private let storeProtocol: StoreProtocol // ✅ Menyuntikkan akses data Toko
    
    init(crmProtocol: CRMProtocol, storeProtocol: StoreProtocol) {
        self.crmProtocol = crmProtocol
        self.storeProtocol = storeProtocol
    }
    
    func loadCustomers(storeId: String) async {
        isLoading = true
        do {
            // Ambil data pelanggan dan cabang secara pararel
            async let fetchCusts = crmProtocol.fetchCustomers(for: storeId)
            async let fetchStore = storeProtocol.fetchStore(storeId: storeId)
            
            self.customers = try await fetchCusts
            if let store = try? await fetchStore {
                self.storeBranches = store.branches
            }
        } catch {
            errorMessage = "Gagal memuat CRM."
        }
        isLoading = false
    }
    
    // ✅ Fungsi Hitung Pelanggan per Cabang Khusus untuk Pop Up Sheet
    func getCustomerCount(for branchId: String, isLoyalOnly: Bool) -> Int {
        let branchCustomers = customers.filter { $0.branchId == branchId }
        if isLoyalOnly {
            return branchCustomers.filter { $0.isLoyal }.count
        }
        return branchCustomers.count
    }
}
