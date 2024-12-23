import SwiftUI
import AuthenticationServices

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Profile")
                    .font(.largeTitle)
                    .padding()
                
                // Sign in with Apple button
                SignInWithAppleButton { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        // Handle successful sign in
                        print("Authorization successful")
                    case .failure(let error):
                        // Handle error
                        print("Authorization failed: \(error.localizedDescription)")
                    }
                }
                .frame(height: 44)
                .padding()
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
} 