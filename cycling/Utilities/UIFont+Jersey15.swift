import SwiftUI

extension Font {
    struct Jersey15 {
        static func largeTitle() -> Font {
            return Font.custom("Jersey15-LargeTitle", size: 40)
        }
        
        static func title() -> Font {
            return Font.custom("Jersey15-Title", size: 30)
        }
        
        static func headline() -> Font {
            return Font.custom("Jersey15-Headline", size: 25)
        }
        
        static func body() -> Font {
            return Font.custom("Jersey15-Body", size: 20)
        }
        
        static func callout() -> Font {
            return Font.custom("Jersey15-Callout", size: 25)
        }
        
        static func subheadline() -> Font {
            return Font.custom("Jersey15-Subheadline", size: 20)
        }
        
        static func footnote() -> Font {
            return Font.custom("Jersey15-Footnote", size: 10)
        }
        
        static func caption() -> Font {
            return Font.custom("Jersey15-Caption", size: 15)
        }
    }
}
