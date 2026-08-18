//
//  OnboardingView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct OnboardingView: View {
    var onFinish: () -> Void = {}

    @State private var step: Int = 1
    @State private var selectedSubjectNames: Set<String> = []
    @State private var dailyGoal: Int = 10

    private let dailyGoalOptions = [5, 10, 15, 20, 30]

    private var isValid: Bool {
        switch step {
        case 1: return !selectedSubjectNames.isEmpty
        default: return true
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            BrandPanel()
                .frame(width: 380)

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header

                    StepIndicator(step: step, total: 2)

                    Group {
                        switch step {
                        case 1:
                            SubjectPicker(selection: $selectedSubjectNames)
                        default:
                            DailyGoalPicker(selection: $dailyGoal, options: dailyGoalOptions)
                        }
                    }

                    Spacer(minLength: 12)

                    HStack(spacing: 12) {
                        if step > 1 {
                            Button {
                                step -= 1
                            } label: {
                                Text("Back")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Theme.dark)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.06)))
                            }
                        }

                        Button {
                            advance()
                        } label: {
                            HStack {
                                Text(step < 2 ? "Continue" : "Get Started").font(.subheadline.weight(.semibold))
                                Image(systemName: "arrow.right")
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isValid ? Theme.dark : Theme.dark.opacity(0.35))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!isValid)
                    }
                }
                .padding(40)
                .frame(maxWidth: 480)
            }
            .frame(maxWidth: .infinity)
            .background(Theme.bg)
        }
    }

    private func advance() {
        if step < 2 {
            step += 1
            return
        }
        onFinish()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            switch step {
            case 1:
                Text("Pick your subjects").font(.title.bold())
                Text("Choose the subjects you want to focus on. You can change this later.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            default:
                Text("Set your daily goal").font(.title.bold())
                Text("How many questions do you want to answer each day?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct SubjectPicker: View {
    @Binding var selection: Set<String>
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    /// Onboarding runs before login (see ContentView's .loggedOut state), so it has no
    /// auth token to call GET /quiz/subjects with — this stays a fixed, name-only pick
    /// list rather than a live fetch. selectedSubjectNames isn't persisted or sent to
    /// the backend anywhere today, so accuracy here doesn't matter yet; SubjectsView is
    /// the one place that reflects the real backend catalog.
    private static let options: [(name: String, icon: String, tint: Color)] = [
        ("Amino Acids & Proteins", "link", .red),
        ("Metabolism & Bioenergetics", "bolt.fill", .orange),
        ("Lipids & Fatty Acids", "drop.fill", .yellow),
        ("Enzymes & Signal Transduction", "arrow.triangle.branch", .blue),
        ("Nucleotides & Gene Expression", "atom", .purple),
        ("Endocrine Biochemistry", "waveform.path.ecg", .pink),
        ("Vitamins & Micronutrients", "leaf.fill", .green)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(Self.options, id: \.name) { option in
                let isSelected = selection.contains(option.name)
                Button {
                    if isSelected {
                        selection.remove(option.name)
                    } else {
                        selection.insert(option.name)
                    }
                } label: {
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(option.tint.opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: option.icon)
                                .font(.subheadline)
                                .foregroundStyle(option.tint)
                        }
                        Text(option.name)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(isSelected ? .white : Theme.dark)
                        Spacer(minLength: 0)
                    }
                    .padding(12)
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

private struct DailyGoalPicker: View {
    @Binding var selection: Int
    let options: [Int]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(options, id: \.self) { option in
                let isSelected = option == selection
                Button {
                    selection = option
                } label: {
                    HStack {
                        Text("\(option) questions / day")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(isSelected ? .white : Theme.dark)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark").foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
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
    OnboardingView()
}
