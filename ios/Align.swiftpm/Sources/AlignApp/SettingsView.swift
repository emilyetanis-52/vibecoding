import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject private var resumeStore = ResumeStore.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("https://your-backend.example.com", text: $settings.serverURLString)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    SecureField("Shared secret", text: $settings.sharedSecret)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("Backend connection")
                } footer: {
                    Text("Must match APP_SHARED_SECRET on your deployed backend. See backend/README.md.")
                }

                if let fileName = resumeStore.fileName {
                    Section {
                        Text(fileName)
                            .foregroundStyle(.secondary)
                        Button("Replace Resume", role: .destructive) {
                            resumeStore.clear()
                            dismiss()
                        }
                    } header: {
                        Text("Base resume")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
