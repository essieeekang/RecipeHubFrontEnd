import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingAddRecipe = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1.0, green: 0.95, blue: 0.97)
                    .edgesIgnoringSafeArea(.all)

                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.currentFilter == .all ? "My Recipes" : viewModel.currentFilter.rawValue)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.purple)
                            
                            if let username = authViewModel.getCurrentUsername() {
                                Text("Welcome back, \(username)!")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button(action: { showingAddRecipe = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.purple)
                            }
                            
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .foregroundColor(.purple)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Filter by:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(RecipeFilter.allCases, id: \.self) { filter in
                                    Button(action: {
                                        viewModel.loadFilteredRecipes(userId: authViewModel.getCurrentUserId(), filter: filter)
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: filter.icon)
                                                .font(.caption)
                                            Text(filter.rawValue)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(viewModel.currentFilter == filter ? Color.purple : Color.white)
                                        .foregroundColor(viewModel.currentFilter == filter ? .white : .purple)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.purple, lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    if viewModel.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                            Text("Loading \(viewModel.currentFilter.rawValue.lowercased()) recipes...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if !viewModel.errorMessage.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            
                            Text(viewModel.errorMessage)
                                .font(.headline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                viewModel.refreshRecipes(userId: authViewModel.getCurrentUserId())
                            }) {
                                Text("Refresh")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.purple)
                                    .cornerRadius(12)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            if viewModel.currentFilter != .all {
                                HStack {
                                    Image(systemName: viewModel.currentFilter.icon)
                                        .foregroundColor(.purple)
                                    Text("Showing \(viewModel.currentFilter.rawValue.lowercased()) recipes (\(viewModel.recipes.count))")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    Button("Show All") {
                                        viewModel.loadFilteredRecipes(userId: authViewModel.getCurrentUserId(), filter: .all)
                                    }
                                    .font(.caption)
                                    .foregroundColor(.purple)
                                }
                                .padding(.horizontal)
                            }
                            
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
                    }
                }
                .navigationBarHidden(true)
            }
        }
        .onAppear {
            viewModel.loadUserRecipes(userId: authViewModel.getCurrentUserId())
        }
        .refreshable {
            viewModel.refreshRecipes(userId: authViewModel.getCurrentUserId())
        }
        .sheet(isPresented: $showingAddRecipe) {
            AddRecipeView { newRecipe in
                viewModel.addRecipe(newRecipe)
            }
        }
    }
}
