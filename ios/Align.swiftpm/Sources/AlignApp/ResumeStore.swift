import Foundation

/// The user's base resume, extracted to plain text once and reused for
/// every future tailor -- matches the "upload once" flow in the mockup.
final class ResumeStore: ObservableObject {
    static let shared = ResumeStore()

    @Published var resumeText: String? {
        didSet { UserDefaults.standard.set(resumeText, forKey: Keys.resumeText) }
    }

    @Published var fileName: String? {
        didSet { UserDefaults.standard.set(fileName, forKey: Keys.fileName) }
    }

    @Published var fileSizeBytes: Int? {
        didSet {
            if let fileSizeBytes {
                UserDefaults.standard.set(fileSizeBytes, forKey: Keys.fileSizeBytes)
            } else {
                UserDefaults.standard.removeObject(forKey: Keys.fileSizeBytes)
            }
        }
    }

    var hasResume: Bool { resumeText != nil }

    var formattedFileSize: String? {
        guard let fileSizeBytes else { return nil }
        return ByteCountFormatter.string(fromByteCount: Int64(fileSizeBytes), countStyle: .file)
    }

    private enum Keys {
        static let resumeText = "resumeStore.resumeText"
        static let fileName = "resumeStore.fileName"
        static let fileSizeBytes = "resumeStore.fileSizeBytes"
    }

    private init() {
        resumeText = UserDefaults.standard.string(forKey: Keys.resumeText)
        fileName = UserDefaults.standard.string(forKey: Keys.fileName)
        let storedSize = UserDefaults.standard.integer(forKey: Keys.fileSizeBytes)
        fileSizeBytes = storedSize > 0 ? storedSize : nil
    }

    func save(resumeText: String, fileName: String, fileSizeBytes: Int) {
        self.resumeText = resumeText
        self.fileName = fileName
        self.fileSizeBytes = fileSizeBytes
    }

    func clear() {
        resumeText = nil
        fileName = nil
        fileSizeBytes = nil
    }
}
