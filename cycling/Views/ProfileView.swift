import AuthenticationServices
import SwiftUI

struct ProfileView: View {
    init() {
        print("ProfileView initialized")
    }
    var body: some View {
        NavigationView {
            VStack {

                Text("Profile")
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
