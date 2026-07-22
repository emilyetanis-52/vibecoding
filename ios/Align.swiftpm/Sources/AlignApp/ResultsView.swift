import SwiftUI

struct ResultsView: View {
    @ObservedObject var flow: AppFlowViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let result = flow.tailorResult {
                    ScoreCard(score: result.alignmentScore, roleGuess: flow.jobTitleGuess)

                    if !result.matched.isEmpty {
                        SectionLabel("What matched")
                        ForEach(result.matched) { item in
                            MatchRow(item: item, kind: .matched)
                        }
                    }

                    if !result.gaps.isEmpty {
                        SectionLabel("Worth reviewing")
                        ForEach(result.gaps) { item in
                            MatchRow(item: item, kind: .gap)
                        }
                    }

                    Button {
                        flow.path.append(.tailoredResume)
                    } label: {
                        Text("View tailored resume")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.alignPrimaryIndigo)
                    .padding(.top, 8)
                }
            }
            .padding(20)
        }
        .background(Color.alignBase.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

private struct ScoreCard: View {
    let score: Int
    let roleGuess: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            let font = Font.system(size: 30, weight: .semibold)
            (
                Text("\(score)").font(font).foregroundColor(Color.alignBase)
                    + Text("%").font(font).foregroundColor(Color.alignAccentBrightAmber)
                    + Text(" aligned").font(font).foregroundColor(Color.alignBase)
            )
            Text(roleGuess)
                .font(.caption)
                .foregroundStyle(Color.alignBase.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.alignPrimaryIndigo)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text.uppercased())
            .font(.caption2.weight(.semibold))
            .foregroundStyle(Color.alignPrimaryIndigo)
            .tracking(0.4)
    }
}

private struct MatchRow: View {
    enum Kind { case matched, gap }

    let item: MatchItem
    let kind: Kind

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(kind == .matched ? "✓" : "!")
                .font(.caption.weight(.bold))
                .foregroundStyle(kind == .matched ? Color.alignSecondaryIndigo : Color.alignAccentAmber)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title).font(.caption.weight(.semibold))
                Text(item.detail).font(.caption2)
            }
            .foregroundStyle(kind == .matched ? Color.alignPrimaryIndigo : Color(hex: 0x412402))
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(kind == .matched ? Color.alignSuccessTint : Color.alignWarningTint)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
