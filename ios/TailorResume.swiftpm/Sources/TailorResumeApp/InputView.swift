import SwiftUI

struct InputView: View {
    @ObservedObject var viewModel: TailorViewModel
    @ObservedObject var settings: AppSettings

    var body: some View {
        Form {
            Section("Your current resume") {
                TextEditor(text: $viewModel.resumeText)
                    .frame(minHeight: 160)
            }

            Section("Job description you're applying to") {
                TextEditor(text: $viewModel.jobDescription)
                    .frame(minHeight: 160)
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    Task { await viewModel.tailor(settings: settings) }
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Tailor My Resume")
                                .bold()
                        }
                        Spacer()
                    }
                }
                .disabled(!viewModel.canSubmit)
            }
        }
    }
}
