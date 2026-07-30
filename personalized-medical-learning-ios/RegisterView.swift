//
//  RegisterView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct RegisterView: View {
    @State private var fullName: String = ""
    @State private var studentId: String = ""
    @State private var academicYear: Int = 1
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RegisterViewModel()
    @State private var didRegister = false
    @State private var didFinishOnboarding = false
    @State private var showLogin = false

    private let years = Array(1...6)

    private var isValid: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty
            && !studentId.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        HStack(spacing: 0) {
            BrandPanel()
                .frame(width: 380)

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header

                    StepIndicator(step: 1, total: 3)

                    VStack(alignment: .leading, spacing: 20) {
                        FieldLabel(text: "Full Name")
                        TextField("e.g. Roxane Harley", text: $fullName)
                            .textFieldStyle(MediQuizFieldStyle())

                        FieldLabel(text: "Student ID")
                        TextField("e.g. STU-2026-0142", text: $studentId)
                            .textInputAutocapitalization(.characters)
                            .textFieldStyle(MediQuizFieldStyle())

                        FieldLabel(text: "Academic Year")
                        YearPicker(selection: $academicYear, years: years)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Spacer(minLength: 12)

                    Button {
                        Task {
                            await viewModel.register(fullName: fullName, studentNumber: studentId, academicYear: academicYear)
                            if viewModel.studentId != nil {
                                didRegister = true
                            }
                        }
                    } label: {
                        HStack {
                            if viewModel.isSubmitting {
                                ProgressView().tint(.white)
                            } else {
                                Text("Continue").font(.subheadline.weight(.semibold))
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
                        Text("Already have an account?").font(.caption).foregroundStyle(.secondary)
                        Button("Log In") {
                            showLogin = true
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
        .fullScreenCover(isPresented: $didRegister) {
            OnboardingView(onFinish: { didFinishOnboarding = true })
                .fullScreenCover(isPresented: $didFinishOnboarding) {
                    RootView()
                }
        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Create your account").font(.title.bold())
            Text("Tell us a bit about yourself to get started.")
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

private struct MediQuizFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06)))
    }
}

private struct YearPicker: View {
    @Binding var selection: Int
    let years: [Int]
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(years, id: \.self) { year in
                let isSelected = year == selection
                Button {
                    selection = year
                } label: {
                    Text("Year \(year)")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(isSelected ? .white : Theme.dark)
                        .background(isSelected ? Theme.dark : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.clear : Color.black.opacity(0.06))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct StepIndicator: View {
    let step: Int
    let total: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...total, id: \.self) { i in
                Capsule()
                    .fill(i <= step ? Theme.dark : Theme.bg)
                    .frame(height: 5)
            }
        }
    }
}

private struct BrandPanel: View {
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
    RegisterView()
}
