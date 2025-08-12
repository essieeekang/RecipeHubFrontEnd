import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(hex: "#E8AEB7")
                .ignoresSafeArea()
            VStack {
                Text("Welcome to RecipeHub!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .foregroundColor(Color(hex: "#3F3F3F"))
                Button("Login") {
                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                }
                .buttonStyle(.borderedProminent)
                Button("Create Account") {
                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: 400)
            .background(Color.white.opacity(0.5))
            .cornerRadius(30)
            .shadow(radius: 15)
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
