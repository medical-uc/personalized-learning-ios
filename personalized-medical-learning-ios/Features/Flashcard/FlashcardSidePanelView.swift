//
//  FlashcardSidePanelView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct FlashcardSidePanelView: View {
    @ObservedObject var viewModel: FlashcardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if !viewModel.cards.isEmpty {
                Text("Card \(viewModel.currentIndex + 1) of \(viewModel.cards.count)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            QuickActionsCard()
            NavigationCard(viewModel: viewModel)
        }
    }
}

struct FlashcardProgressPopoverContent: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                StudyProgressCard()
                TodayStatsCard()
            }
            .padding(20)
        }
        .frame(width: 340, height: 560)
    }
}

struct StudyProgressCard: View {
    private var progress: Double {
        Double(FlashcardData.cardsStudied) / Double(FlashcardData.cardsGoal)
    }

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Text("Study Progress").font(.headline)
                Spacer()
                Button("Edit Goal") {}
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.dark)
            }

            ZStack {
                Circle()
                    .stroke(Theme.bg, lineWidth: 10)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Theme.dark, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(FlashcardData.cardsStudied)").font(.title.bold())
                    Text("/ \(FlashcardData.cardsGoal)").font(.caption2).foregroundStyle(.secondary)
                }
            }
            .frame(width: 140, height: 140)

            Text("Cards Studied")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Image(systemName: "flame.fill").foregroundStyle(.orange)
                Text("\(FlashcardData.dayStreak)").font(.subheadline.bold())
                Text("Day Streak").font(.caption).foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Theme.bg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct TodayStatsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today's Stats").font(.headline)

            VStack(spacing: 12) {
                ForEach(FlashcardData.todayStats) { stat in
                    HStack(spacing: 10) {
                        Image(systemName: stat.icon)
                            .foregroundStyle(Theme.dark)
                            .frame(width: 18)
                        Text(stat.label).font(.subheadline)
                        Spacer()
                        Text(stat.value).font(.subheadline.weight(.semibold))
                    }
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct QuickActionsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Quick Actions").font(.headline)

            VStack(spacing: 10) {
                ForEach(FlashcardData.quickActions) { action in
                    Button {} label: {
                        HStack(spacing: 12) {
                            Image(systemName: action.icon)
                                .foregroundStyle(Theme.dark)
                                .frame(width: 20)
                            Text(action.title).font(.subheadline.weight(.medium))
                            Spacer()
                        }
                        .foregroundStyle(Theme.dark)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Theme.bg)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct NavigationCard: View {
    @ObservedObject var viewModel: FlashcardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Navigation").font(.headline)

            HStack(spacing: 20) {
                Button(action: viewModel.goToPrevious) {
                    Image(systemName: "chevron.left")
                        .frame(width: 36, height: 36)
                        .background(Theme.bg)
                        .clipShape(Circle())
                }
                .disabled(viewModel.currentIndex == 0)

                Text("\(min(viewModel.currentIndex + 1, viewModel.totalCards)) / \(viewModel.totalCards)")
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity, alignment: .center)

                Button(action: viewModel.goToNext) {
                    Image(systemName: "chevron.right")
                        .frame(width: 36, height: 36)
                        .background(Theme.bg)
                        .clipShape(Circle())
                }
                .disabled(viewModel.currentIndex + 1 >= viewModel.totalCards)
            }
            .foregroundStyle(Theme.dark)
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    ScrollView {
        FlashcardSidePanelView(viewModel: FlashcardViewModel())
            .padding()
            .frame(width: 340)
    }
    .background(Theme.bg)
}
