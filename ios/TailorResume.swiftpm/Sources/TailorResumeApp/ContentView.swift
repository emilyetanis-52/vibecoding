import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TailorViewModel()
    @StateObject private var settings = AppSettings.shared
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            InputView(viewModel: viewModel, settings: settings)
                .navigationTitle("Tailor Resume")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView(settings: settings)
                }
                .navigationDestination(item: $viewModel.tailoredResume) { tailored in
                    ResultView(tailoredResume: tailored) {
                        viewModel.reset()
                    }
                }
        }
    }
}
