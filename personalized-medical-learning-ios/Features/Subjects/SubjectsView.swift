//
//  SubjectsView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct SubjectsView: View {
    var onBack: () -> Void = {}

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject private var viewModel = SubjectsViewModel()
    @State private var selectedSubjectID: String?
    @State private var searchText = ""
    @State private var selectedLevelFilter: MasteryLevel?

    private var selectedSubject: StudySubject? {
        guard let selectedSubjectID else { return nil }
        return viewModel.subjects.first { $0.id == selectedSubjectID }
    }

    private var filteredSubjects: [StudySubject] {
        viewModel.subjects.filter { subject in
            let matchesSearch = searchText.isEmpty
                || subject.name.localizedCaseInsensitiveContains(searchText)
            let matchesLevel = selectedLevelFilter == nil
                || MasteryLevel(pKnow: subject.progress) == selectedLevelFilter
            return matchesSearch && matchesLevel
        }
    }

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                HStack(alignment: .top, spacing: 24) {
                    Group {
                        if selectedSubject == nil {
                            listPane.frame(maxWidth: .infinity)
                        } else {
                            listPane.frame(width: 380)
                        }
                    }

                    if selectedSubject != nil {
                        detailPane
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        listPane
                        detailPane
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .padding(.horizontal, horizontalSizeClass == .regular ? 24 : 0)
        .padding(.top, horizontalSizeClass == .regular ? 24 : 0)
        .padding(.bottom, horizontalSizeClass == .regular ? 24 : 0)
        .background(Theme.bg)
        .task {
            await viewModel.loadSubjects()
            if selectedSubjectID == nil {
                selectedSubjectID = viewModel.subjects.first?.id
            }
        }
    }

    private var listPane: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                SubjectSearchField(text: $searchText)

                MasteryLevelFilterBar(selectedLevel: $selectedLevelFilter)

                content
            }
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
            Text("No subjects match your filters.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
        } else {
            VStack(spacing: 14) {
                ForEach(filteredSubjects) { subject in
                    SubjectRow(
                        subject: subject,
                        isSelected: subject.id == selectedSubjectID
                    )
                    .onTapGesture { selectedSubjectID = subject.id }
                }
            }
        }
    }

    @ViewBuilder
    private var detailPane: some View {
        if let selectedSubject {
            ScrollView {
                SubjectDetailView(subject: selectedSubject, onBack: { self.selectedSubjectID = nil })
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

private struct MasteryLevelFilterBar: View {
    @Binding var selectedLevel: MasteryLevel?

    private let levels: [MasteryLevel] = [.needsWork, .developing, .strong]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(label: "All", tint: Theme.dark, isSelected: selectedLevel == nil) {
                    selectedLevel = nil
                }
                ForEach(levels, id: \.self) { level in
                    FilterChip(label: level.label, tint: level.tint, isSelected: selectedLevel == level) {
                        selectedLevel = selectedLevel == level ? nil : level
                    }
                }
            }
        }
    }
}

private struct FilterChip: View {
    let label: String
    let tint: Color
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? Color.white : tint)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? tint : tint.opacity(0.12))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct SubjectRow: View {
    let subject: StudySubject
    let isSelected: Bool

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

                Text("\(Int(subject.progress * 100))%")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)

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
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? Theme.dark : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    RootView()
}
