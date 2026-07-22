import SwiftUI

struct ResultView: View {
    let tailoredResume: String
    let onStartOver: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            Text(tailoredResume)
                .font(.custom("Georgia", size: 16, relativeTo: .body))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .background(Color.alignBase)
        .navigationTitle("Tailored Resume")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ShareLink(item: tailoredResume)
                    .tint(.alignSecondaryIndigo)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Start Over") {
                    onStartOver()
                    dismiss()
                }
                .tint(.alignSecondaryIndigo)
            }
        }
    }
}
