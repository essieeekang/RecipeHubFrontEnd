//
//  HomeView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

// Features/Home/Views/HomeView.swift

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1.0, green: 0.95, blue: 0.97)
                    .edgesIgnoringSafeArea(.all)

                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        Text("My Recipes")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        Spacer()
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.purple)
                        }
                    }
                    .padding(.horizontal)

                    // Recipe List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.recipes) { recipe in
                                NavigationLink(destination: RecipeDetailView(viewModel: RecipeDetailViewModel(recipe: recipe))) {
                                    RecipeCardView(recipe: recipe)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
                .navigationBarHidden(true)
            }
        }
    }
}
