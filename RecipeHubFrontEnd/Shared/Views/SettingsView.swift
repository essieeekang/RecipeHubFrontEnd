//
//  SettingsView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.title)
                    .foregroundColor(.purple)
                
                Spacer()
                
                Button("Logout") {
                    authViewModel.logout()
                }
                .buttonStyle(FilledButtonStyle())
                .padding()
            }
            .navigationTitle("Settings")
        }
    }
}
