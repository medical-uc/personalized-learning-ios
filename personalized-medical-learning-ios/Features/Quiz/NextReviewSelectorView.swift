//
//  NextReviewSelectorView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

/// Student's own choice of when to see this question again, overriding the
/// streak-computed schedule for just this attempt — see LogAttemptRequest.nextReviewDays.
/// nil (the default) means "let the backend decide" via the normal streak schedule.
enum NextReviewOption: Int, CaseIterable, Identifiable {
    case oneDay = 1
    case threeDays = 3
    case oneWeek = 7
    case twoWeeks = 14

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .oneDay: return "1 Day"
        case .threeDays: return "3 Days"
        case .oneWeek: return "1 Week"
        case .twoWeeks: return "2 Weeks"
        }
    }
}

struct NextReviewSelectorView: View {
    @Binding var selection: NextReviewOption?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("When should we review this again?")
                .font(.headline)

            HStack(spacing: 12) {
                AutoOptionButton(isSelected: selection == nil) {
                    selection = nil
                }
                ForEach(NextReviewOption.allCases) { option in
                    NextReviewOptionButton(
                        option: option,
                        isSelected: selection == option
                    ) {
                        selection = option
                    }
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct AutoOptionButton: View {
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: "wand.and.stars")
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : Theme.dark)
                Text("Auto")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(isSelected ? .white : Theme.dark)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Theme.dark : Theme.bg)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

private struct NextReviewOptionButton: View {
    let option: NextReviewOption
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : Theme.dark)
                Text(option.label)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(isSelected ? .white : Theme.dark)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Theme.dark : Theme.bg)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NextReviewSelectorView(selection: .constant(nil))
        .padding()
        .background(Theme.bg)
}
