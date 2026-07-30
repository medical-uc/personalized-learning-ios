//
//  SettingsView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct SettingsView: View {
    var onLogOut: () -> Void = {}

    @State private var isLoggingOut = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                VStack(alignment: .leading, spacing: 14) {
                    Text("Account").font(.headline)

                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Student ID").font(.caption2).foregroundStyle(.secondary)
                            Text(SessionManager.studentId ?? "—").font(.subheadline.weight(.semibold))
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Button {
                    Task { await logOut() }
                } label: {
                    HStack {
                        if isLoggingOut {
                            ProgressView()
                        } else {
                            Text("Log Out").font(.subheadline.weight(.semibold))
                            Image(systemName: "arrow.right.square")
                        }
                    }
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(isLoggingOut)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Theme.bg)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Settings").font(.largeTitle.bold())
            Text("Manage your account.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 24)
    }

    private func logOut() async {
        isLoggingOut = true
        defer { isLoggingOut = false }

        if let token = SessionManager.token {
            try? await APIClient.shared.logoutStudent(token: token)
        }

        SessionManager.end()
        onLogOut()
    }
}

#Preview {
    RootView()
}
