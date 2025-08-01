//
//  SearchView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//
import SwiftUI

struct SearchView: View {
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search recipes...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Spacer()
                Text("Results will appear here")
                    .foregroundColor(.gray)
                Spacer()
            }
            .navigationTitle("Search")
        }
    }
}
