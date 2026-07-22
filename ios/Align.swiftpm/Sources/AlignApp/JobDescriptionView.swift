import SwiftUI

struct JobDescriptionView: View {
    @ObservedObject var flow: AppFlowViewModel
    @ObservedObject var settings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Paste the job description")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.alignPrimaryIndigo)

            Text("Copy the full posting — the more detail, the better the match.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextEditor(text: $flow.jobDescription)
                .font(.footnote)
                .padding(10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color(hex: 0xE4DFD2)))
                .frame(maxHeight: .infinity)

            if let tailorErrorMessage = flow.tailorErrorMessage {
                Text(tailorErrorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button {
                Task { await flow.startTailoring(settings: settings) }
            } label: {
                Text("Tailor my resume")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.alignPrimaryIndigo)
            .disabled(flow.jobDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(20)
        .background(Color.alignBase.ignoresSafeArea())
    }
}
