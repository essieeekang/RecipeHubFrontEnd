import SwiftUI

struct IngredientRowView: View {
    @Binding var ingredient: IngredientInput
    let onRemove: () -> Void
    let isDisabled: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Quantity
            TextField("Qty", value: $ingredient.quantity, format: .number)
                .textFieldStyle(RoundedField())
                .frame(width: 80)
                .disabled(isDisabled)
            
            // Unit
            TextField("Unit", text: $ingredient.unit)
                .textFieldStyle(RoundedField())
                .frame(width: 100)
                .disabled(isDisabled)
            
            // Name
            TextField("Ingredient name", text: $ingredient.name)
                .textFieldStyle(RoundedField())
                .disabled(isDisabled)
            
            // Remove button
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
            // Step number
            Text("\(stepNumber).")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.purple)
                .frame(width: 30, alignment: .leading)
            
            // Instruction text
            TextField("Enter instruction step", text: $instruction, axis: .vertical)
                .textFieldStyle(RoundedField())
                .lineLimit(2...4)
                .disabled(isDisabled)
            
            // Remove button
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
            .disabled(isDisabled)
        }
    }
} 