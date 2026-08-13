//
//  SubjectsView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct SubjectsView: View {
    var onBack: () -> Void = {}

    @StateObject private var viewModel = SubjectsViewModel()
    @State private var selectedSubjectID: String?
    @State private var searchText = ""
    @State private var masterySubjectID: String?

    private var masterySubject: StudySubject? {
        guard let masterySubjectID else { return nil }
        return viewModel.subjects.first { $0.id == masterySubjectID }
    }

    private var selectedSubject: StudySubject? {
        guard let selectedSubjectID else { return nil }
        return viewModel.subjects.first { $0.id == selectedSubjectID }
    }

    private var filteredSubjects: [StudySubject] {
        guard !searchText.isEmpty else { return viewModel.subjects }
        return viewModel.subjects.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        Group {
            if let selectedSubject {
                ScrollView {
                    SubjectDetailView(subject: selectedSubject, onBack: { self.selectedSubjectID = nil })
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 24)
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header

                        SubjectSearchField(text: $searchText)

                        content
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(Theme.bg)
        .task {
            await viewModel.loadSubjects()
        }
        .sheet(item: Binding<StudySubject?>(
            get: { masterySubject },
            set: { masterySubjectID = $0?.id }
        )) { subject in
            SubjectMasteryDetailView(subject: subject, onSelectTopic: { _ in
                masterySubjectID = nil
                selectedSubjectID = subject.id
            })
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.subjects.isEmpty {
            Text("Loading subjects…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
        } else if let errorMessage = viewModel.errorMessage, viewModel.subjects.isEmpty {
            SubjectsErrorView(message: errorMessage) {
                Task { await viewModel.loadSubjects() }
            }
        } else if filteredSubjects.isEmpty {
            Text("No subjects match your search.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
        } else {
            VStack(spacing: 14) {
                ForEach(filteredSubjects) { subject in
                    SubjectRow(subject: subject, onTapMastery: { masterySubjectID = subject.id })
                        .onTapGesture { selectedSubjectID = subject.id }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Subjects").font(.largeTitle.bold())
            Text("Explore all medical subjects and track your progress.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

private struct SubjectsErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry", action: onRetry)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Theme.dark)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

private struct SubjectSearchField: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search subjects", text: $text)
                .textFieldStyle(.plain)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06)))
    }
}

private struct SubjectRow: View {
    let subject: StudySubject
    var onTapMastery: () -> Void = {}

    private var level: MasteryLevel { MasteryLevel(pKnow: subject.progress) }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(subject.tint.opacity(0.12))
                    .frame(width: 56, height: 56)
                Image(systemName: subject.icon)
                    .font(.title2)
                    .foregroundStyle(subject.tint)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(subject.name).font(.subheadline.bold())

                Button(action: onTapMastery) {
                    HStack(spacing: 3) {
                        Text("\(Int((subject.progress * 100).rounded()))%")
                        Image(systemName: "info.circle")
                    }
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(level.tint)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(level.tint.opacity(0.12))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Text("\(subject.topics.count) topics · \(subject.questionCount) questions · \(subject.flashcardCount) flashcards")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    RootView()
}
