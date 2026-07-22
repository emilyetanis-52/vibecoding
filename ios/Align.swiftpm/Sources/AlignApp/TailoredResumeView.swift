import SwiftUI

struct TailoredResumeView: View {
    @ObservedObject var flow: AppFlowViewModel

    var body: some View {
        ScrollView {
            Text(flow.tailorResult?.tailoredResume ?? "")
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
                ShareLink(item: flow.tailorResult?.tailoredResume ?? "")
                    .tint(Color.alignSecondaryIndigo)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Start Over") {
                    flow.startOver()
                }
                .tint(Color.alignSecondaryIndigo)
            }
        }
    }
}
