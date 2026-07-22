import SwiftUI

struct PaywallView: View {
    @ObservedObject var flow: AppFlowViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Choose your plan")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.alignPrimaryIndigo)

            Text("You've used your free tailor this month.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            PlanCard(
                name: "Free",
                price: "1 tailored resume / month",
                features: ["Watermarked export", "1 template"],
                featured: false
            )

            PlanCard(
                name: "Align Pro — \(proPriceLabel)",
                price: "Unlimited tailored resumes",
                features: ["Unlimited exports, no watermark", "All templates", "Version history"],
                featured: true
            )

            if let errorMessage = flow.storeKit.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Spacer(minLength: 0)

            Button {
                Task { await flow.storeKit.purchasePro() }
            } label: {
                if flow.storeKit.isPurchasing {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text("Start free trial")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.alignPrimaryIndigo)
            .disabled(flow.storeKit.isPurchasing)

            Button("Restore purchases") {
                Task { await flow.storeKit.restorePurchases() }
            }
            .font(.footnote)
            .foregroundStyle(Color.alignSecondaryIndigo)
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(Color.alignBase.ignoresSafeArea())
        .onChange(of: flow.storeKit.isPro) { _, isPro in
            if isPro {
                flow.path.removeLast()
            }
        }
    }

    private var proPriceLabel: String {
        flow.storeKit.proProduct?.displayPrice.appending("/mo") ?? "$9.99/mo"
    }
}

private struct PlanCard: View {
    let name: String
    let price: String
    let features: [String]
    let featured: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.alignPrimaryIndigo)
            Text(price)
                .font(.caption)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 3) {
                ForEach(features, id: \.self) { feature in
                    HStack(alignment: .top, spacing: 6) {
                        Text("✓").foregroundStyle(Color.alignSecondaryIndigo)
                        Text(feature).foregroundStyle(.secondary)
                    }
                    .font(.caption2)
                }
            }
            .padding(.top, 4)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(featured ? Color.alignSecondaryIndigo : Color(hex: 0xE4DFD2), lineWidth: featured ? 2 : 1)
        )
    }
}
