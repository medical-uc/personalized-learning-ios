//
//  SubjectsView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct SubjectsView: View {
    var onBack: () -> Void = {}

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTab: SubjectTab = .allSubjects
    @State private var selectedSubject: Subject? = SubjectData.subjects.first

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
    }

    private var listPane: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                SubjectTabBar(selectedTab: $selectedTab)

                VStack(spacing: 14) {
                    ForEach(SubjectData.subjects) { subject in
                        SubjectRow(
                            subject: subject,
                            isSelected: subject.id == selectedSubject?.id
                        )
                        .onTapGesture { selectedSubject = subject }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var detailPane: some View {
        if let selectedSubject {
            ScrollView {
                SubjectDetailView(subject: selectedSubject, onBack: { self.selectedSubject = nil })
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

private struct SubjectTabBar: View {
    @Binding var selectedTab: SubjectTab

    var body: some View {
        HStack(spacing: 24) {
            ForEach(SubjectTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 8) {
                        Text(tab.rawValue)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selectedTab == tab ? Theme.dark : .secondary)
                        Rectangle()
                            .fill(selectedTab == tab ? Theme.dark : Color.clear)
                            .frame(height: 2)
                    }
                }
            }
            Spacer()
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.bg).frame(height: 1)
        }
    }
}

private struct SubjectRow: View {
    let subject: Subject
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

                Text("\(subject.concepts) concepts · \(subject.questions) questions · \(subject.flashcards) flashcards")
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
