//
//  ContentView.swift
//  personalized-medical-learning-ios
//
//  Created by Michael Eko on 29/07/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = SessionManager.isValid

    var body: some View {
        if isLoggedIn {
            RootView(onLogOut: { isLoggedIn = false })
        } else {
            LoginView(onLogIn: { isLoggedIn = true })
        }
    }
}

#Preview {
    ContentView()
}
