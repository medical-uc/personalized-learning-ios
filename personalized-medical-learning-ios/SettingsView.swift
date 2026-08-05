//
//  SettingsView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct SettingsView: View {
    var onLogOut: () -> Void = {}

    @State private var isLoggingOut = false
    @State private var errorMessage: String?
    @State private var profile: StudentProfileResponse?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                VStack(alignment: .leading, spacing: 14) {
                    Text("Account").font(.headline)

                    VStack(alignment: .leading, spacing: 12) {
                        if let profile {
                            profileRow(label: "Full Name", value: profile.fullName)
                            profileRow(label: "Student Number", value: profile.studentNumber)
                            profileRow(label: "Academic Year", value: "Year \(profile.academicYear)")
                        } else {
                            profileRow(label: "Student ID", value: SessionManager.studentId ?? "—")
                        }
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
        .task {
            profile = try? await APIClient.shared.getStudentProfile()
        }
    }

    private func profileRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption2).foregroundStyle(.secondary)
            Text(value).font(.subheadline.weight(.semibold))
        }
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
