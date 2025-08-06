//
//  BooksListView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import SwiftUI

struct RecipeBooksView: View {
    @StateObject private var viewModel = RecipeBooksViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingCreateBook = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1.0, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("My Books")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.purple)
                            
                            Text("Organize your recipes into collections")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: { showingCreateBook = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.purple)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Content
                    if viewModel.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                            Text("Loading your books...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if !viewModel.errorMessage.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "book.closed")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            
                            Text(viewModel.errorMessage)
                                .font(.headline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            Button(action: { showingCreateBook = true }) {
                                Text("Create Your First Book")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.purple)
                                    .cornerRadius(12)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.books) { book in
                                    NavigationLink(destination: BookDetailView(book: book)) {
                                        RecipeBookCardView(book: book)
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
        .sheet(isPresented: $showingCreateBook) {
            CreateBookView(viewModel: viewModel)
        }
        .onAppear {
            // Load user's books when view appears
            viewModel.loadUserBooks(userId: authViewModel.getCurrentUserId())
        }
        .onChange(of: viewModel.books.count) { _, newCount in
            print("RecipeBooksView: Books count changed to \(newCount)")
            print("Current books: \(viewModel.books.map { "\($0.name) (ID: \($0.id))" })")
        }
        .refreshable {
            // Pull to refresh functionality
            viewModel.refreshBooks(userId: authViewModel.getCurrentUserId())
        }
    }
}

#Preview {
    RecipeBooksView()
}
