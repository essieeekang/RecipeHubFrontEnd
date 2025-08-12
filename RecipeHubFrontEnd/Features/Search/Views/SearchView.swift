//
//  SearchView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1.0, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Search Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Search Recipes")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        
                        Text("Find recipes by \(viewModel.searchType.rawValue.lowercased())")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Search Type Selector
                    HStack {
                        Text("Search by:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Picker("Search Type", selection: $viewModel.searchType) {
                            ForEach(SearchType.allCases, id: \.self) { searchType in
                                Text(searchType.rawValue)
                                    .tag(searchType)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: viewModel.searchType) { _ in
                            viewModel.clearSearch()
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Search Bar
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField(viewModel.searchType.placeholder, text: $viewModel.searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .onSubmit {
                                    viewModel.searchOnSubmit()
                                }
                            
                            if !viewModel.searchText.isEmpty {
                                Button(action: viewModel.clearSearch) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    .padding(.horizontal)
                    
                    // Search Results
                    if viewModel.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                            Text("Searching...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if !viewModel.errorMessage.isEmpty && viewModel.hasSearched {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            
                            Text(viewModel.errorMessage)
                                .font(.headline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            Text("Try searching for different terms")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.searchResults.isEmpty && !viewModel.hasSearched {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            
                            Text("Search for recipes")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text("Enter terms to find recipes")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Search Results Summary
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Found \(viewModel.searchResults.count) recipe\(viewModel.searchResults.count == 1 ? "" : "s")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                if !viewModel.recipeBookResults.isEmpty {
                                    Text("•")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    Text("\(viewModel.recipeBookResults.count) recipe book\(viewModel.recipeBookResults.count == 1 ? "" : "s")")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Search Results List
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                // Recipes Section
                                if !viewModel.searchResults.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Recipes")
                                            .font(.headline)
                                            .foregroundColor(.purple)
                                            .padding(.horizontal)
                                        
                                        ForEach(viewModel.searchResults) { recipe in
                                            NavigationLink(destination: RecipeDetailView(viewModel: RecipeDetailViewModel(recipe: recipe))) {
                                                RecipeCardView(recipe: recipe)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                                
                                // Recipe Books Section
                                if !viewModel.recipeBookResults.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Divider()
                                            .padding(.horizontal)
                                        
                                        Text("Recipe Books")
                                            .font(.headline)
                                            .foregroundColor(.purple)
                                            .padding(.horizontal)
                                        
                                        ForEach(viewModel.recipeBookResults) { recipeBook in
                                            SearchRecipeBookCardView(recipeBook: recipeBook)
                                                .padding(.horizontal)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    SearchView()
}
