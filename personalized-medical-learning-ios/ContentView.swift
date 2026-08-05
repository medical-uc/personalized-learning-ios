//
//  ContentView.swift
//  personalized-medical-learning-ios
//
//  Created by Michael Eko on 29/07/26.
//

import SwiftUI

struct ContentView: View {
    private enum SessionState {
        case checking
        case loggedIn
        case loggedOut
    }

    @State private var sessionState: SessionState = SessionManager.isValid ? .checking : .loggedOut

    var body: some View {
        switch sessionState {
        case .checking:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .task {
                    if let session = await APIClient.shared.checkSession(), session.authenticated {
                        SessionManager.updateStudentId(session.studentId)
                        sessionState = .loggedIn
                    } else {
                        SessionManager.end()
                        sessionState = .loggedOut
                    }
                }
        case .loggedIn:
            RootView(onLogOut: { sessionState = .loggedOut })
                .onReceive(NotificationCenter.default.publisher(for: .sessionExpired)) { _ in
                    sessionState = .loggedOut
                }
        case .loggedOut:
            LoginView(onLogIn: { sessionState = .loggedIn })
        }
    }
}

#Preview {
    ContentView()
}
