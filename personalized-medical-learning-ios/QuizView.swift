//
//  QuizView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct QuizView: View {
    var onBack: () -> Void = {}

    @State private var confidenceSelection: ConfidenceLevel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                QuizHeaderView(onBack: onBack)

                VStack(alignment: .leading, spacing: 20) {
                    QuestionCardView(question: QuizData.sampleQuestion)
                    ConfidenceSelectorView(selection: $confidenceSelection)
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
