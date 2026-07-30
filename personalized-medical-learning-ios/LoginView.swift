//
//  LoginView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct LoginView: View {
    var onLogIn: () -> Void = {}

    @State private var studentId: String = ""
    @State private var showRegister = false
    @StateObject private var viewModel = LoginViewModel()

    private var isValid: Bool {
        !studentId.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        HStack(spacing: 0) {
            LoginBrandPanel()
                .frame(width: 380)

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header

                    VStack(alignment: .leading, spacing: 20) {
                        FieldLabel(text: "Student ID")
                        TextField("e.g. STU-2026-0142", text: $studentId)
                            .textInputAutocapitalization(.characters)
                            .textFieldStyle(LoginFieldStyle())
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Spacer(minLength: 12)

                    Button {
                        Task {
                            await viewModel.logIn(studentNumber: studentId)
                        }
                    } label: {
                        HStack {
                            if viewModel.isSubmitting {
                                ProgressView().tint(.white)
                            } else {
                                Text("Log In").font(.subheadline.weight(.semibold))
                                Image(systemName: "arrow.right")
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isValid ? Theme.dark : Theme.dark.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(!isValid || viewModel.isSubmitting)

                    HStack {
                        Spacer()
                        Text("Don't have an account?").font(.caption).foregroundStyle(.secondary)
                        Button("Sign Up") {
                            showRegister = true
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.dark)
                        Spacer()
                    }
                }
                .padding(40)
                .frame(maxWidth: 480)
            }
            .frame(maxWidth: .infinity)
            .background(Theme.bg)
        }
        .onChange(of: viewModel.didLogIn) { _, didLogIn in
            if didLogIn { onLogIn() }
        }
        .fullScreenCover(isPresented: $showRegister) {
            RegisterView(onLogIn: onLogIn)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome back").font(.title.bold())
            Text("Enter your student ID to continue your studies.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

private struct FieldLabel: View {
    let text: String
    var body: some View {
        Text(text).font(.subheadline.weight(.semibold))
    }
}

private struct LoginFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06)))
    }
}

private struct LoginBrandPanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 8) {
                Image(systemName: "cross.fill").foregroundStyle(.white)
                Text("MediQuiz").font(.title2.bold()).foregroundStyle(.white)
            }
            .padding(.top, 40)
            .padding(.leading, 40)

            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                Text("Learn medicine,\none quiz at a time.")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                Text("Track your progress, compete with peers, and master every subject.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
            }
            .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.dark)
    }
}

#Preview {
    LoginView()
}
