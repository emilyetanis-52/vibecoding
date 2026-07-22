import SwiftUI

struct ContentView: View {
    @StateObject private var flow = AppFlowViewModel()
    @StateObject private var settings = AppSettings.shared
    @State private var showingSettings = false

    var body: some View {
        NavigationStack(path: $flow.path) {
            root
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbar }
                .sheet(isPresented: $showingSettings) {
                    SettingsView(settings: settings)
                }
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .jobDescription:
                        JobDescriptionView(flow: flow, settings: settings)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar { toolbar }
                    case .aligning:
                        LoadingView(flow: flow)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar { toolbar }
                    case .results:
                        ResultsView(flow: flow)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar { toolbar }
                    case .tailoredResume:
                        TailoredResumeView(flow: flow)
                    case .paywall:
                        PaywallView(flow: flow)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar { toolbar }
                    }
                }
        }
    }

    @ViewBuilder
    private var root: some View {
        if flow.resumeStore.hasResume {
            JobDescriptionView(flow: flow, settings: settings)
        } else {
            UploadResumeView(flow: flow, settings: settings)
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            AlignWordmark()
        }
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape")
            }
        }
    }
}
