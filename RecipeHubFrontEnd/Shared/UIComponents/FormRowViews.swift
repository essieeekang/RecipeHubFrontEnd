import SwiftUI

struct IngredientRowView: View {
    @Binding var ingredient: IngredientInput
    let onRemove: () -> Void
    let isDisabled: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Qty", value: $ingredient.quantity, format: .number)
                .textFieldStyle(RoundedField())
                .frame(width: 80)
                .disabled(isDisabled)
            
            TextField("Unit", text: $ingredient.unit)
                .textFieldStyle(RoundedField())
                .frame(width: 100)
                .disabled(isDisabled)
            
            TextField("Ingredient name", text: $ingredient.name)
                .textFieldStyle(RoundedField())
                .disabled(isDisabled)
            
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
            .disabled(isDisabled)
        }
    }
}

struct InstructionRowView: View {
    @Binding var instruction: String
    let stepNumber: Int
    let onRemove: () -> Void
    let isDisabled: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(stepNumber).")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.purple)
                .frame(width: 30, alignment: .leading)
            
            TextField("Enter instruction step", text: $instruction, axis: .vertical)
                .textFieldStyle(RoundedField())
                .lineLimit(2...4)
                .disabled(isDisabled)
            
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
            .disabled(isDisabled)
        }
    }
} 
