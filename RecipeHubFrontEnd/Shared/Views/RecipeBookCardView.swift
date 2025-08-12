import SwiftUI

struct RecipeBookCardView: View {
    let book: RecipeBook
    @ObservedObject var viewModel: RecipeBooksViewModel
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var isDeleting = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(book.displayName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: book.isPublic ? "globe" : "lock")
                            .font(.caption)
                            .foregroundColor(book.isPublic ? .green : .orange)
                        
                        Text(book.isPublic ? "Public" : "Private")
                            .font(.caption)
                            .foregroundColor(book.isPublic ? .green : .orange)
                    }
                    
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundColor(.purple)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isDeleting)
                    
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isDeleting)
                }
            }
            
            Text(book.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack(spacing: 4) {
                Image(systemName: "doc.text")
                    .font(.caption)
                    .foregroundColor(.purple)
                
                Text("\(book.recipeCount) recipe\(book.recipeCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !book.recipeIds.isEmpty {
                HStack(spacing: 4) {
                    ForEach(0..<min(3, book.recipeIds.count), id: \.self) { _ in
                        Circle()
                            .fill(Color.purple.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                    
                    if book.recipeIds.count > 3 {
                        Text("+\(book.recipeIds.count - 3)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .sheet(isPresented: $showingEditSheet) {
            EditBookView(book: book, viewModel: viewModel)
        }
        .alert("Delete Recipe Book", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteBook()
            }
        } message: {
            Text("Are you sure you want to delete '\(book.name)'?")
        }
        .overlay(
            Group {
                if isDeleting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                        .scaleEffect(0.8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(16)
                }
            }
        )
    }
    
    private func deleteBook() {
        isDeleting = true
        
        viewModel.deleteBook(book) { success in
            isDeleting = false
        }
    }
}
