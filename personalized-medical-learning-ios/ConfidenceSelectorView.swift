//
//  ConfidenceSelectorView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

enum ConfidenceLevel: String, CaseIterable, Identifiable {
    case guessing = "Guessing"
    case unsure = "Unsure"
    case confident = "Confident"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .guessing: return "questionmark.circle"
        case .unsure: return "circle.lefthalf.filled"
        case .confident: return "checkmark.seal.fill"
        }
    }

    var tint: Color {
        switch self {
        case .guessing: return .orange
        case .unsure: return .blue
        case .confident: return .green
        }
    }
}

struct ConfidenceSelectorView: View {
    @Binding var selection: ConfidenceLevel?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How confident are you?")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(ConfidenceLevel.allCases) { level in
                    ConfidenceOptionButton(
                        level: level,
                        isSelected: selection == level
                    ) {
                        selection = level
                    }
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct ConfidenceOptionButton: View {
    let level: ConfidenceLevel
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: level.icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : level.tint)
                Text(level.rawValue)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(isSelected ? .white : Theme.dark)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? level.tint : Theme.bg)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ConfidenceSelectorView(selection: .constant(.unsure))
        .padding()
        .background(Theme.bg)
}
