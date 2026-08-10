//
//  SidebarView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct SidebarView: View {
    var selection: SidebarItem
    var onSelect: (SidebarItem) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "cross.fill")
                    .foregroundStyle(Theme.dark)
                Text("MediQuiz")
                    .font(.title2.bold())
                    .foregroundStyle(Theme.dark)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 24)

            VStack(spacing: 4) {
                ForEach(SidebarItem.allCases) { item in
                    SidebarRow(item: item, isSelected: item == selection)
                        .onTapGesture { onSelect(item) }
                }
            }
            .padding(.horizontal, 12)

            Spacer()

            ProfileFooter()
                .padding(.horizontal, 12)
                .padding(.bottom, 16)
        }
        .frame(width: 240)
        .background(Color.white)
    }
}

private struct SidebarRow: View {
    let item: SidebarItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .frame(width: 20)
            Text(item.rawValue)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .foregroundStyle(isSelected ? .white : Theme.dark)
        .background(isSelected ? Theme.dark : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct ProfileFooter: View {
    @State private var energyBalance: Int?

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 8) {
                Circle()
                    .fill(Theme.mint)
                    .frame(width: 56, height: 56)
                    .overlay(Image(systemName: "person.fill").foregroundStyle(Theme.dark))

                Text(SessionManager.fullName ?? "Student")
                    .font(.subheadline.bold())

                Text("Expert")
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Theme.mint)
                    .clipShape(Capsule())

                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill").foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(energyBalance.map(String.init) ?? "–").font(.subheadline.bold())
                        Text("Energy Points").font(.caption2).foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Theme.bg)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            HStack {
                Image(systemName: "gift.fill")
                Text("Invite Friends").font(.subheadline.weight(.medium))
                Spacer()
                Image(systemName: "chevron.right").font(.caption)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Theme.bg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .task {
            energyBalance = try? await APIClient.shared.getEnergy().energy
        }
        .onReceive(NotificationCenter.default.publisher(for: .energyAwarded)) { notification in
            if let balance = notification.userInfo?[EnergyAwardedKey.balance] as? Int {
                energyBalance = balance
            }
        }
    }
}

#Preview {
    SidebarView(selection: .dashboard)
}
