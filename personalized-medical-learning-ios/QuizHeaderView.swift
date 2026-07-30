//
//  QuizHeaderView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct QuizHeaderView: View {
    var onBack: () -> Void = {}

    @State private var isNavigatorPresented = false

    var body: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.left")
                    Text("Back to Dashboard")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.dark)
            }

            Spacer()

            Button {
                isNavigatorPresented = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.grid.2x2")
                    Text("Navigation")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.dark)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .popover(isPresented: $isNavigatorPresented) {
                QuizNavigatorPopoverContent()
            }

            Button {} label: {
                Image(systemName: "bookmark")
                    .foregroundStyle(Theme.dark)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button {} label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(Theme.dark)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.top, 24)
    }
}

#Preview {
    QuizHeaderView()
        .padding()
        .background(Theme.bg)
}
