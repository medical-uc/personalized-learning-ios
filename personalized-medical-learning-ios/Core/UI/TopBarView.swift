//
//  TopBarView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct TopBarView: View {
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Good morning,")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(SessionManager.fullName ?? "Student")
                    .font(.title.bold())
            }
            .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 12)
        }
        .padding(.top, 24)
    }
}

#Preview {
    TopBarView()
        .padding()
        .background(Theme.bg)
}
