//
//  WelcomeView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1.0, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()

                VStack(spacing: 40) {
                    Text("🍳 RecipeHub")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.purple)

                    Text("Cook. Share. Love.")
                        .font(.headline)
                        .foregroundColor(.gray)

                    NavigationLink("Log In", destination: LoginView())
                        .buttonStyle(FilledButtonStyle())

                    NavigationLink("Create Account", destination: AddUserView())
                        .buttonStyle(OutlineButtonStyle())
                }
                .padding()
            }
        }
    }
}

#Preview {
    WelcomeView()
}
