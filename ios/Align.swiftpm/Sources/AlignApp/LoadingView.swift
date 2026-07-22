import SwiftUI

struct LoadingView: View {
    @ObservedObject var flow: AppFlowViewModel

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            ProgressView()
                .controlSize(.large)
                .tint(Color.alignSecondaryIndigo)

            VStack(spacing: 4) {
                Text("Aligning your resume")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.alignPrimaryIndigo)
                Text("to \(flow.jobTitleGuess)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(AppFlowViewModel.loadingSteps.enumerated()), id: \.offset) { index, step in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(index <= flow.loadingStepIndex ? Color.alignSecondaryIndigo : Color(hex: 0xE4DFD2))
                            .frame(width: 6, height: 6)
                        Text(step)
                            .font(.caption)
                            .foregroundStyle(index <= flow.loadingStepIndex ? Color.alignPrimaryIndigo : .secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.alignBase.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}
