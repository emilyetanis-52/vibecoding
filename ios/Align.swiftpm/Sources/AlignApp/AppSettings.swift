import Foundation

/// User-editable connection settings, stored on-device.
/// Point `serverURL` at your deployed backend (see backend/README) and set
/// `sharedSecret` to the same value as APP_SHARED_SECRET on the server.
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var serverURLString: String {
        didSet { UserDefaults.standard.set(serverURLString, forKey: Keys.serverURL) }
    }

    @Published var sharedSecret: String {
        didSet { UserDefaults.standard.set(sharedSecret, forKey: Keys.sharedSecret) }
    }

    private enum Keys {
        static let serverURL = "serverURLString"
        static let sharedSecret = "sharedSecret"
    }

    private init() {
        serverURLString = UserDefaults.standard.string(forKey: Keys.serverURL)
            ?? "http://localhost:3000"
        sharedSecret = UserDefaults.standard.string(forKey: Keys.sharedSecret) ?? ""
    }

    var serverURL: URL? {
        URL(string: serverURLString)
    }
}
