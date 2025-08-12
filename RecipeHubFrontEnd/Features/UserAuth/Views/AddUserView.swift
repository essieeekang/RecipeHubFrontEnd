import SwiftUI

struct AddUserView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let onBack: () -> Void
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack{
            Color(red: 1.0, green: 0.95, blue: 0.97).ignoresSafeArea()
            VStack(spacing: 24) {
                HStack {
                    Button("Back") {
                        onBack()
                    }
                    .foregroundColor(.gray)
                    Spacer()
                }
                
                Text("Join RecipeHub")
                    .font(.title)
                    .fontWeight(.bold)
                
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedField())
                    .textInputAutocapitalization(.never)
                    .onChange(of: username) { _, newValue in
                        authViewModel.username = newValue
                    }
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedField())
                    .textInputAutocapitalization(.never)
                    .onChange(of: email) { _, newValue in
                        authViewModel.email = newValue
                    }
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedField())
                    .textInputAutocapitalization(.never)
                    .onChange(of: password) { _, newValue in
                        authViewModel.password = newValue
                    }
                
                Button("Create Account") {
                    print("Create Account button tapped")
                    print("Username: \(authViewModel.username)")
                    print("Email: \(authViewModel.email)")
                    print("Password: \(authViewModel.password)")
                    authViewModel.addUser {
                        print("Add user completion handler called")
                    }
                }
                .buttonStyle(FilledButtonStyle())
                .disabled(authViewModel.isLoading)
                
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                        .scaleEffect(0.8)
                }
                
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding()
        }
    }
}
