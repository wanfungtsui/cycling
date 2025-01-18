import SwiftUI

// Utility class to customize the navigation bar appearance
class NavigationBarCustomizer {
    // Function to customize the appearance of the navigation bar
    static func customizeNavigationBar() {
        // Create a new UINavigationBarAppearance instance
        let appearance = UINavigationBarAppearance()
        
        // Set the background color of the navigation bar
        appearance.backgroundColor = UIColor(named: "TabBackground")
        
        // Remove the shadow color to make the navigation bar appear flat
        appearance.shadowColor = .clear

        // Remove the "<" back icon by setting a clear image
        let clearImage = UIImage() // Create an empty UIImage
        appearance.setBackIndicatorImage(clearImage, transitionMaskImage: clearImage)

        // Customize the style of the back button title
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white, // Customize text color
            .font: UIFont(name: "Jersey15-Regular", size: 20) ?? UIFont.boldSystemFont(ofSize: 15), // Customize font
        ]
        appearance.backButtonAppearance.normal.titleTextAttributes = attributes
        appearance.backButtonAppearance.highlighted.titleTextAttributes = attributes

        // Apply the customized appearance to all navigation bars
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}


