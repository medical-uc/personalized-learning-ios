//
//  DashboardView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                TopBarView()

                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: 20) {
                        LeftColumnView()
                            .frame(width: 300)

                        CenterColumnView()
                            .frame(minWidth: 320, maxWidth: .infinity)

                        RightColumnView()
                            .frame(width: 300)
                    }

                    VStack(alignment: .leading, spacing: 20) {
                        CenterColumnView()
                        LeftColumnView()
                        RightColumnView()
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
