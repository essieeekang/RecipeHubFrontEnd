//
//  SearchViewModel.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [Recipe] = []
    @Published var recipeBookResults: [RecipeBook] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var hasSearched = false
    @Published var searchType: SearchType = .recipeTitle
    
    private var searchCancellable: AnyCancellable?
    
    init() {
        // Debounce search to avoid too many API calls
        searchCancellable = $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .sink { [weak self] searchTerm in
                self?.performSearch(searchTerm: searchTerm)
            }
    }
    
    func performSearch(searchTerm: String) {
        guard !searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            hasSearched = false
            return
        }
        
        isLoading = true
        errorMessage = ""
        hasSearched = true
        
        print("Searching for recipes with term: '\(searchTerm)' by \(searchType.rawValue)")
        
        SearchRecipesAction(searchTerm: searchTerm, searchType: searchType).call { [weak self] searchResponse in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                let recipes = searchResponse.recipes ?? []
                let recipeBooks = searchResponse.recipeBooks ?? []
                
                if recipes.isEmpty && recipeBooks.isEmpty {
                    self?.errorMessage = "No recipes or recipe books found matching '\(searchTerm)'"
                    self?.searchResults = []
                    self?.recipeBookResults = []
                } else {
                    self?.searchResults = recipes
                    self?.recipeBookResults = recipeBooks
                    self?.errorMessage = ""
                    print("Found \(recipes.count) recipes and \(recipeBooks.count) recipe books matching '\(searchTerm)' by \(self?.searchType.rawValue ?? "unknown")")
                }
            }
        }
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
        recipeBookResults = []
        errorMessage = ""
        hasSearched = false
    }
    
    func searchOnSubmit() {
        // Trigger search immediately when user submits
        performSearch(searchTerm: searchText)
    }
} 