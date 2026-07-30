//
//  BookmarkView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct BookmarkView: View {
    var onBack: () -> Void = {}

    @State private var selectedKind: BookmarkKind = .all

    private var filteredItems: [BookmarkItem] {
        selectedKind == .all
            ? BookmarkData.items
            : BookmarkData.items.filter { $0.kind == selectedKind }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                KindFilterBar(selectedKind: $selectedKind)

                if filteredItems.isEmpty {
                    EmptyBookmarksView()
                } else {
                    VStack(spacing: 14) {
                        ForEach(filteredItems) { item in
                            BookmarkRow(item: item)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Theme.bg)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Bookmarks").font(.largeTitle.bold())
            Text("Quiz questions, flashcards, and subjects you've saved.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 24)
    }
}

private struct KindFilterBar: View {
    @Binding var selectedKind: BookmarkKind

    var body: some View {
        HStack(spacing: 10) {
            ForEach(BookmarkKind.allCases) { kind in
                let isSelected = kind == selectedKind
                Button {
                    selectedKind = kind
                } label: {
                    Text(kind.rawValue)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(isSelected ? .white : Theme.dark)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(isSelected ? Theme.dark : Color.white)
                        .clipShape(Capsule())
                }
            }
            Spacer()
        }
    }
}

private struct BookmarkRow: View {
    let item: BookmarkItem

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(item.tint.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: item.icon)
                    .font(.title3)
                    .foregroundStyle(item.tint)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                Text(item.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 10) {
                Button {} label: {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(Theme.dark)
                }
                Text(item.savedAgo)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct EmptyBookmarksView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bookmark")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No bookmarks yet")
                .font(.headline)
            Text("Save questions, flashcards, and subjects to find them here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    RootView()
}
