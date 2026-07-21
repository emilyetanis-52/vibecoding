import SwiftUI

struct ResultView: View {
    let tailoredResume: String
    let onStartOver: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            Text(tailoredResume)
                .font(.body)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle("Tailored Resume")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ShareLink(item: tailoredResume)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Start Over") {
                    onStartOver()
                    dismiss()
                }
            }
        }
    }
}
