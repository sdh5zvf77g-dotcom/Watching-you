import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var cameraService = CameraService()
    @StateObject private var speechService = SpeechService()
    private let visionService = VisionService()
    
    @State private var showAPIKeyAlert = false
    @State private var apiKeyInput = ""
    
    var body: some View {
        ZStack {
            if cameraService.isAuthorized {
                CameraPreview(session: cameraService.session)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.gray)
                    Text(cameraService.error ?? "Camera access required")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            
            VStack {
                HStack {
                    Text("I Am Watching You")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                    
                    Spacer()
                    
                    Button {
                        showAPIKeyAlert = true
                    } label: {
                        Image(systemName: "key.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                if !appState.descriptionText.isEmpty {
                    DescriptionView(
                        text: appState.descriptionText,
                        isSpeaking: speechService.isSpeaking,
                        onSpeakAgain: {
                            speechService.speak(appState.descriptionText)
                        },
                        onClear: {
                            speechService.stop()
                            appState.descriptionText = ""
                            appState.lastCapturedImage = nil
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Button {
                    Task { await captureAndDescribe() }
                } label: {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 80, height: 80)
                        
                        if appState.isProcessing {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Image(systemName: "eye.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(.red)
                        }
                    }
                }
                .disabled(appState.isProcessing || !cameraService.isAuthorized)
                .padding(.bottom, 40)
            }
        }
        .animation(.easeInOut, value: appState.descriptionText)
        .alert("OpenAI API Key", isPresented: $showAPIKeyAlert) {
            TextField("sk-...", text: $apiKeyInput)
                .textInputAutocapitalization(.never)
            Button("Save") {
                appState.openAIAPIKey = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter your OpenAI API key. Stored only in memory for this session. Never commit real keys.")
        }
        .alert("Error", isPresented: .constant(appState.errorMessage != nil)) {
            Button("OK") { appState.errorMessage = nil }
        } message: {
            Text(appState.errorMessage ?? "")
        }
    }
    
    private func captureAndDescribe() async {
        appState.isProcessing = true
        appState.errorMessage = nil
        appState.descriptionText = ""
        
        defer { appState.isProcessing = false }
        
        guard let image = await cameraService.capturePhoto() else {
            appState.errorMessage = "Failed to capture photo"
            return
        }
        
        appState.lastCapturedImage = image
        
        do {
            let description = try await visionService.describeImage(image, apiKey: appState.openAIAPIKey)
            appState.descriptionText = description
            speechService.speak(description)
        } catch {
            appState.errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
