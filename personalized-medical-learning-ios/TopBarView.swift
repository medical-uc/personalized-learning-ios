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
                Text("Roxane Harley")
                    .font(.title.bold())
                Text("Cardiology Department - 3rd floor")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.bg)
                    .clipShape(Capsule())
                    .padding(.top, 4)
            }
            .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 12)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                Text("Search topics, questions...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minWidth: 140, idealWidth: 320, maxWidth: 320)
            .background(Color.white)
            .clipShape(Capsule())

            Button {} label: {
                Image(systemName: "bell")
                    .foregroundStyle(Theme.dark)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
            }

            Button {} label: {
                HStack(spacing: 6) {
                    Image(systemName: "viewfinder")
                    Text("Scanning")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(Theme.dark)
                .clipShape(Capsule())
            }
        }
        .padding(.top, 24)
    }
}

#Preview {
    TopBarView()
        .padding()
        .background(Theme.bg)
}
