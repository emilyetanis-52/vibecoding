import StoreKit

/// Align Pro subscription. The product ID here must exist in App Store
/// Connect (In-App Purchases) before this works against the real store --
/// see Align.storekit for local simulator testing in the meantime
/// (Xcode: Product > Scheme > Edit Scheme > Run > Options > StoreKit
/// Configuration).
@MainActor
final class StoreKitService: ObservableObject {
    static let shared = StoreKitService()

    static let proMonthlyID = "com.emilytanis.align.pro.monthly"

    @Published private(set) var isPro = false
    @Published private(set) var products: [Product] = []
    @Published var errorMessage: String?
    @Published private(set) var isPurchasing = false

    private var updatesTask: Task<Void, Never>?

    private init() {
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                    await self?.refreshEntitlements()
                }
            }
        }
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    var proProduct: Product? {
        products.first(where: { $0.id == Self.proMonthlyID })
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: [Self.proMonthlyID])
        } catch {
            errorMessage = "Couldn't load subscription options. Check your connection and try again."
        }
    }

    func purchasePro() async {
        guard let product = proProduct else {
            errorMessage = "Subscription isn't available yet."
            return
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await refreshEntitlements()
                } else {
                    errorMessage = "Purchase couldn't be verified."
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = "Purchase failed. Please try again."
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            errorMessage = "Couldn't restore purchases."
        }
    }

    func refreshEntitlements() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == Self.proMonthlyID {
                active = true
            }
        }
        isPro = active
    }
}
