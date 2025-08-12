# RecipeHub 📚👨‍🍳

A modern iOS recipe management app built with SwiftUI that helps users organize, discover, and share their favorite recipes.

## ✨ Features

### 🏠 **Home & Recipe Management**
- **Personal Recipe Collection** - View all your recipes in one place
- **Smart Filtering** - Filter by favorites, cooked status, or view all
- **Recipe Cards** - Beautiful, informative recipe previews
- **Pull-to-Refresh** - Easy recipe list updates

### 🔍 **Search & Discovery**
- **Multi-Mode Search** - Search by recipe title or author username
- **Recipe Results** - Find recipes from other users
- **Recipe Book Discovery** - Discover curated recipe collections
- **Interactive Results** - Tap to view recipe details and book contents

### 📖 **Recipe Books**
- **Organize Recipes** - Group recipes into themed collections
- **Privacy Control** - Public or private recipe books
- **Easy Management** - Create, edit, and delete recipe books
- **Recipe Addition** - Add recipes to books with simple taps

### 🍳 **Recipe Creation & Management**
- **Rich Recipe Builder** - Add ingredients, instructions, and images
- **Image Support** - Upload photos or take new pictures with camera
- **Ingredient Management** - Add quantities, units, and names
- **Step-by-Step Instructions** - Create detailed cooking steps
- **Recipe Editing** - Update existing recipes anytime

### 🔄 **Recipe Sharing & Collaboration**
- **Fork Recipes** - Create your own version of others' recipes
- **Attribution** - Always credit original recipe creators
- **Original Recipe Links** - Navigate to source recipes easily
- **Community Building** - Share and discover new recipes

### 👤 **User Management**
- **Profile Management** - Update username, email, and password
- **Personal Dashboard** - View your recipes and books
- **Session Persistence** - Stay logged in across app sessions

## 🏗️ Architecture

### **Design Pattern**
- **MVVM (Model-View-ViewModel)** - Clean separation of concerns
- **SwiftUI** - Modern declarative UI framework
- **Combine Framework** - Reactive programming for data flow

### **Project Structure**
```
RecipeHubFrontEnd/
├── Features/                    # Feature-based organization
│   ├── AddRecipe/             # Create new recipes
│   ├── BooksList/             # Manage recipe books
│   ├── EditRecipe/            # Edit existing recipes
│   ├── ForkRecipe/            # Fork recipes from others
│   ├── Home/                  # Main recipe dashboard
│   ├── RecipeDetail/          # View recipe details
│   ├── Search/                # Search functionality
│   └── UserAuth/              # Authentication
├── Shared/                     # Shared components
│   ├── Models/                # Data models
│   ├── UIComponents/          # Reusable UI components
│   ├── Utilities/             # Helper functions
│   └── Views/                 # Common views
└── RecipeHubFrontEnd.xcodeproj # Xcode project file
```

### **Key Components**
- **APIConfig** - Centralized API configuration and environment management
- **Global State Management** - Persistent data across view recreations
- **Custom UI Components** - Consistent design system
- **Network Actions** - Clean API communication layer

## 🚀 Getting Started

### **Prerequisites**
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+
- macOS 14.0+ (for development)

### **Installation**
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd RecipeHubFrontEnd
   ```

2. Open the project in Xcode:
   ```bash
   open RecipeHubFrontEnd.xcodeproj
   ```

3. Select your target device or simulator

4. Build and run the project (⌘+R)

## 📱 Usage Guide

### **First Time Setup**
1. Launch the app
2. Tap "Sign Up" to create an account
3. Enter your username, email, and password
4. Start creating your first recipe!

### **Creating Recipes**
1. Tap the "+" button on the home screen
2. Fill in recipe details:
   - Title and description
   - Ingredients with quantities and units
   - Step-by-step instructions
   - Add a photo (optional)
3. Tap "Create Recipe" to save

### **Organizing with Recipe Books**
1. Go to "My Books" tab
2. Tap "Create New Book"
3. Enter book name, description, and privacy settings
4. Add recipes to your books from recipe details

### **Searching Recipes**
1. Go to the Search tab
2. Choose search type: "Recipe Title" or "Author"
3. Enter your search terms
4. Browse results and tap to view details

### **Forking Recipes**
1. Find a recipe you like (from search or browsing)
2. Tap "Fork Recipe" on the recipe details page
3. Customize the recipe to your liking
4. Save as your own version

## 🔧 Development

### **Adding New Features**
1. **Create Feature Structure**:
   ```
   Features/NewFeature/
   ├── Actions/          # API calls
   ├── Models/           # Data models
   ├── ViewModels/       # Business logic
   └── Views/            # User interface
   ```

2. **Add API Endpoints**:
   ```swift
   // In APIConfig.swift
   static let newEndpoint = "/api/new-feature"
   
   static func newFeatureURL(param: String) -> URL? {
       return buildURL(for: Endpoints.newEndpoint, pathParameters: ["param": param])
   }
   ```

3. **Create Actions**:
   ```swift
   struct NewFeatureAction {
       func call(completion: @escaping (Result) -> Void) {
           guard let url = APIConfig.newFeatureURL(param: "value") else { return }
           // Implementation
       }
   }
   ```

### **Code Style Guidelines**
- Use SwiftUI for all new views
- Follow MVVM architecture pattern
- Use `@Published` for reactive data
- Implement proper error handling
- Add comprehensive logging for debugging

### **Testing**
- Test on multiple iOS versions
- Verify API connectivity
- Validate user input handling

## 🌐 API Integration

### **Base URL Configuration**
The app automatically handles API communication. All endpoints are defined in `APIConfig.swift` and support:

- **Path Parameters**: `{userId}`, `{recipeId}`, etc.
- **Query Parameters**: Search terms, filters, etc.

### **Supported Endpoints**
- **Users**: Authentication, profile management
- **Recipes**: CRUD operations, search, forking
- **Recipe Books**: Collections, organization
- **Search**: Multi-mode recipe discovery

## 🎨 UI/UX Design

### **Design System**
- **Color Palette**: Purple primary with white/gray accents
- **Typography**: System fonts with consistent sizing
- **Spacing**: 8pt grid system for consistent layouts
- **Components**: Reusable card views and buttons

### **Custom Components**
- `RecipeCardView` - Recipe preview cards
- `ButtonStyles` - Consistent button styling
- `RoundedField` - Custom text field appearance

## 🐛 Troubleshooting

### **Common Issues**
1. **API Connection Errors**:
   - Check `APIConfig.swift` for correct connection to backend
   - Verify server is running and accessible
   - Check network connectivity

2. **Build Errors**:
   - Clean build folder (⌘+Shift+K)
   - Update Xcode to latest version
   - Check Swift version compatibility

3. **Runtime Issues**:
   - Check console logs for error messages
   - Verify API response formats
   - Test with different data sets

## 📄 License

This project is part of a capstone project.

## 🙏 Acknowledgments

- **SwiftUI Team** - For the amazing UI framework
- **iOS Community** - For best practices and patterns
- **Recipe Enthusiasts** - For inspiration and feedback


