import Foundation

/// Tracks how many resumes have been tailored this calendar month, to gate
/// the free tier (1/month, per the paywall screen) without needing a
/// backend account system yet. Resets automatically when the month rolls
/// over.
final class UsageTracker: ObservableObject {
    static let shared = UsageTracker()

    static let freeTailorsPerMonth = 1

    @Published private(set) var tailorsThisMonth: Int

    private enum Keys {
        static let count = "usageTracker.count"
        static let periodKey = "usageTracker.periodKey"
    }

    private init() {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: Keys.periodKey) == Self.currentPeriodKey() {
            tailorsThisMonth = defaults.integer(forKey: Keys.count)
        } else {
            tailorsThisMonth = 0
            defaults.set(0, forKey: Keys.count)
            defaults.set(Self.currentPeriodKey(), forKey: Keys.periodKey)
        }
    }

    func canTailorForFree(isPro: Bool) -> Bool {
        isPro || tailorsThisMonth < Self.freeTailorsPerMonth
    }

    func recordTailor() {
        rolloverIfNeeded()
        tailorsThisMonth += 1
        let defaults = UserDefaults.standard
        defaults.set(tailorsThisMonth, forKey: Keys.count)
        defaults.set(Self.currentPeriodKey(), forKey: Keys.periodKey)
    }

    private func rolloverIfNeeded() {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: Keys.periodKey) != Self.currentPeriodKey() {
            tailorsThisMonth = 0
        }
    }

    private static func currentPeriodKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        formatter.timeZone = .current
        return formatter.string(from: Date())
    }
}
