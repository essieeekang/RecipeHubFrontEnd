import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentView: AuthView = .welcome
    
    enum AuthView {
        case welcome, login, signup
    }
    
    var body: some View {
        Group {
            switch currentView {
            case .welcome:
                welcomeContent
            case .login:
                LoginView(onBack: {
                    withAnimation {
                        currentView = .welcome
                    }
                })
                .environmentObject(authViewModel)
                .transition(.move(edge: .trailing))
            case .signup:
                AddUserView(onBack: {
                    withAnimation {
                        currentView = .welcome
                    }
                })
                .environmentObject(authViewModel)
                .transition(.move(edge: .trailing))
            }
        }
        .onChange(of: authViewModel.isLoggedIn) { _, newValue in
            if newValue {
                currentView = .welcome
            }
        }
    }
    
    private var welcomeContent: some View {
        ZStack {
            Color(red: 1.0, green: 0.95, blue: 0.97)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Recipe Hub")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.purple)

                Text("Cook. Share. Love.")
                    .font(.headline)
                    .foregroundColor(.gray)

                Button("Log In") {
                    withAnimation {
                        currentView = .login
                    }
                }
                .buttonStyle(FilledButtonStyle())

                Button("Create Account") {
                    withAnimation {
                        currentView = .signup
                    }
                }
                .buttonStyle(OutlineButtonStyle())
            }
            .padding()
        }
    }
}
