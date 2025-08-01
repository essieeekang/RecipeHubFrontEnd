//
//  RootView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

// App/RootView.swift

import SwiftUI

struct RootView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
            if let atsSettings = Bundle.main.infoDictionary?["NSAppTransportSecurity"] as? [String: Any] {
                if let allowsArbitraryLoads = atsSettings["NSAllowsArbitraryLoads"] as? Bool {
                    print("NSAllowsArbitraryLoads: \(allowsArbitraryLoads)")
                } else {
                    print("NSAllowsArbitraryLoads key not found")
                }
            } else {
                print("NSAppTransportSecurity not found")
            }
        }

    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                MainTabView()
            } else {
                WelcomeView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
