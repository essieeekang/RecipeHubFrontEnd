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
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var hasSearched = false
    
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
        
        print("Searching for recipes with term: '\(searchTerm)'")
        
        SearchRecipesAction(searchTerm: searchTerm).call { [weak self] recipes in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if recipes.isEmpty {
                    self?.errorMessage = "No recipes found matching '\(searchTerm)'"
                    self?.searchResults = []
                } else {
                    self?.searchResults = recipes
                    self?.errorMessage = ""
                    print("Found \(recipes.count) recipes matching '\(searchTerm)'")
                }
            }
        }
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
        errorMessage = ""
        hasSearched = false
    }
    
    func searchOnSubmit() {
        // Trigger search immediately when user submits
        performSearch(searchTerm: searchText)
    }
} 