import SwiftUI

struct DescriptionView: View {
    let text: String
    let isSpeaking: Bool
    let onSpeakAgain: () -> Void
    let onClear: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "eye.fill")
                    .foregroundStyle(.red)
                Text("I Am Watching You")
                    .font(.headline)
                Spacer()
                
                if isSpeaking {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundStyle(.green)
                        .symbolEffect(.variableColor.iterative)
                }
            }
            
            Text(text)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            HStack(spacing: 12) {
                Button {
                    onSpeakAgain()
                } label: {
                    Label("Speak Again", systemImage: "speaker.wave.2")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                
                Button {
                    onClear()
                } label: {
                    Label("Clear", systemImage: "xmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(.black.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
    }
}
