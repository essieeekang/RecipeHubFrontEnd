//
//  AppUtilities.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation
import SwiftUI

// Global singleton to hold recipe data that survives SwiftUI view recreation
class GlobalRecipeHolder: ObservableObject {
    static let shared = GlobalRecipeHolder()
    
    @Published var currentOriginalRecipe: Recipe?
    @Published var currentOriginalError: String?
    @Published var currentOriginalLoading: Bool = false
    
    private init() {}
    
    func setRecipe(_ recipe: Recipe) {
        DispatchQueue.main.async {
            self.currentOriginalRecipe = recipe
            self.currentOriginalError = nil
            self.currentOriginalLoading = false
            print("🔧 GlobalRecipeHolder: Set recipe - \(recipe.title)")
        }
    }
    
    func setError(_ error: String) {
        DispatchQueue.main.async {
            self.currentOriginalRecipe = nil
            self.currentOriginalError = error
            self.currentOriginalLoading = false
            print("🔧 GlobalRecipeHolder: Set error - \(error)")
        }
    }
    
    func setLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            self.currentOriginalLoading = loading
            print("🔧 GlobalRecipeHolder: Set loading - \(loading)")
        }
    }
    
    func clear() {
        DispatchQueue.main.async {
            self.currentOriginalRecipe = nil
            self.currentOriginalError = nil
            self.currentOriginalLoading = false
            print("🔧 GlobalRecipeHolder: Cleared all data")
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

extension Double {
    var clean: String {
        return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
