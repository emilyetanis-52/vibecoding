import SwiftUI
import UniformTypeIdentifiers

struct UploadResumeView: View {
    @ObservedObject var flow: AppFlowViewModel
    @ObservedObject var settings: AppSettings

    @State private var showingFileImporter = false

    private static let supportedTypes: [UTType] = {
        var types: [UTType] = [.pdf, .plainText]
        if let docx = UTType(filenameExtension: "docx") {
            types.append(docx)
        }
        return types
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Add your resume")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.alignPrimaryIndigo)

            Text("Upload your current resume. We'll use it as the base for every tailored version.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let fileName = flow.resumeStore.fileName {
                ResumeCard(fileName: fileName, detail: flow.resumeStore.formattedFileSize.map { "\($0) · uploaded" } ?? "uploaded")
            }

            if let uploadErrorMessage = flow.uploadErrorMessage {
                Text(uploadErrorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button {
                showingFileImporter = true
            } label: {
                VStack(spacing: 10) {
                    if flow.isExtracting {
                        ProgressView()
                    } else {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 38, height: 38)
                            .background(Color.alignSuccessTint)
                            .foregroundStyle(Color.alignSecondaryIndigo)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text("Drop a file or tap to browse\nPDF, DOCX, or TXT")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 160)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                    .foregroundStyle(Color(hex: 0xC9BFA0))
            )
            .disabled(flow.isExtracting)

            Spacer(minLength: 0)

            Button {
                flow.path.append(.jobDescription)
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.alignPrimaryIndigo)
            .disabled(!flow.resumeStore.hasResume)
        }
        .padding(20)
        .background(Color.alignBase.ignoresSafeArea())
        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: Self.supportedTypes) { result in
            switch result {
            case .success(let url):
                Task { await flow.uploadResume(fileURL: url, settings: settings) }
            case .failure(let error):
                flow.uploadErrorMessage = error.localizedDescription
            }
        }
    }
}

private struct ResumeCard: View {
    let fileName: String
    let detail: String

    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.alignSuccessTint)
                .frame(width: 30, height: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(fileName)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.alignPrimaryIndigo)
                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12).strokeBorder(Color(hex: 0xE4DFD2))
        )
    }
}
