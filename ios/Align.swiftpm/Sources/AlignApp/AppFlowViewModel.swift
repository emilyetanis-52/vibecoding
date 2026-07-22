import Combine
import Foundation

enum AppRoute: Hashable {
    case jobDescription
    case aligning
    case results
    case tailoredResume
    case paywall
}

@MainActor
final class AppFlowViewModel: ObservableObject {
    @Published var path: [AppRoute] = []

    @Published var jobDescription: String = ""
    @Published var isExtracting = false
    @Published var loadingStepIndex = 0
    @Published var tailorResult: TailorResult?
    @Published var uploadErrorMessage: String?
    @Published var tailorErrorMessage: String?

    let resumeStore = ResumeStore.shared
    let usageTracker = UsageTracker.shared
    let storeKit = StoreKitService.shared

    private var cancellables: Set<AnyCancellable> = []

    init() {
        resumeStore.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        usageTracker.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        storeKit.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    var jobTitleGuess: String {
        jobDescription
            .split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: true)
            .first
            .map(String.init) ?? "this role"
    }

    func uploadResume(fileURL: URL, settings: AppSettings) async {
        isExtracting = true
        uploadErrorMessage = nil
        defer { isExtracting = false }

        let didStartAccessing = fileURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing { fileURL.stopAccessingSecurityScopedResource() }
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let mimeType = Self.mimeType(for: fileURL)
            let resumeText = try await TailorService.extractResume(
                fileData: data,
                filename: fileURL.lastPathComponent,
                mimeType: mimeType,
                settings: settings
            )
            resumeStore.save(resumeText: resumeText, fileName: fileURL.lastPathComponent, fileSizeBytes: data.count)
            path.append(.jobDescription)
        } catch {
            uploadErrorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func startTailoring(settings: AppSettings) async {
        guard let resumeText = resumeStore.resumeText else { return }

        guard usageTracker.canTailorForFree(isPro: storeKit.isPro) else {
            path.append(.paywall)
            return
        }

        tailorErrorMessage = nil
        loadingStepIndex = 0
        path.append(.aligning)

        async let stepAnimation: Void = animateLoadingSteps()
        async let tailorCall = TailorService.tailorResume(
            resumeText: resumeText,
            jobDescription: jobDescription,
            settings: settings
        )

        do {
            let result = try await tailorCall
            _ = await stepAnimation
            loadingStepIndex = Self.loadingSteps.count - 1
            tailorResult = result
            usageTracker.recordTailor()
            path.removeLast()
            path.append(.results)
        } catch {
            tailorErrorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            path.removeLast()
        }
    }

    func startOver() {
        jobDescription = ""
        tailorResult = nil
        tailorErrorMessage = nil
        path = []
    }

    func replaceResume() {
        resumeStore.clear()
        path = []
    }

    static let loadingSteps = [
        "Reading job requirements",
        "Mapping your experience",
        "Rewriting for relevance",
    ]

    private func animateLoadingSteps() async {
        for index in 0..<(Self.loadingSteps.count - 1) {
            loadingStepIndex = index
            try? await Task.sleep(nanoseconds: 900_000_000)
        }
    }

    private static func mimeType(for url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "pdf": return "application/pdf"
        case "docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "txt": return "text/plain"
        default: return "application/octet-stream"
        }
    }
}
