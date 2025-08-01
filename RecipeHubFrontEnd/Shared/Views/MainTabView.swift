//
//  MainTabView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            RecipeBooksView()
                .tabItem {
                    Label("My Books", systemImage: "book.closed")
                }

            AddRecipeView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
        .accentColor(.purple)
        .environmentObject(authViewModel)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
