import Foundation
import SwiftUI

@MainActor
class AppState: ObservableObject {
    @Published var descriptionText: String = ""
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?
    @Published var lastCapturedImage: UIImage?
    
    // Never commit a real key. Use the in-app key button.
    var openAIAPIKey: String = ""
}
