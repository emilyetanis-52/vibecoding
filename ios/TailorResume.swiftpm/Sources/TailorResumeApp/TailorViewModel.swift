import Foundation

@MainActor
final class TailorViewModel: ObservableObject {
    @Published var resumeText: String = ""
    @Published var jobDescription: String = ""
    @Published var tailoredResume: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    var canSubmit: Bool {
        !resumeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !jobDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !isLoading
    }

    func tailor(settings: AppSettings) async {
        guard canSubmit else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            tailoredResume = try await TailorService.tailorResume(
                resumeText: resumeText,
                jobDescription: jobDescription,
                settings: settings
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reset() {
        tailoredResume = nil
        errorMessage = nil
    }
}
