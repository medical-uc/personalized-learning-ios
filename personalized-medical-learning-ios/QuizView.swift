//
//  QuizView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct QuizView: View {
    var onBack: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                QuizHeaderView(onBack: onBack)

                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: 20) {
                        QuestionCardView(question: QuizData.sampleQuestion)
                            .frame(minWidth: 400, maxWidth: .infinity)

                        QuizSidePanelView()
                            .frame(width: 320)
                    }

                    VStack(alignment: .leading, spacing: 20) {
                        QuestionCardView(question: QuizData.sampleQuestion)
                        QuizSidePanelView()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Theme.bg)
    }
}

#Preview {
    RootView()
}
