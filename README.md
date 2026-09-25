# I Am Watching You

An iPhone app that uses the camera to observe the world and describe it in natural sentences — as if the phone is calmly studying and reporting what it sees.

## Features

- Live camera preview
- One-tap capture + AI description (GPT-4o Vision)
- Natural spoken narration (text-to-speech)
- Clean dark UI
- Easy to extend

## Requirements

- Xcode 15+
- iOS 17+
- Real iPhone (camera required)
- OpenAI API key

## How to open in Xcode

1. Open Xcode
2. File → New → Project → iOS → App
3. Product Name: `IAmWatchingYou`
4. Interface: SwiftUI, Language: Swift
5. Save the project
6. Delete the default `ContentView.swift` and `IAmWatchingYouApp.swift` that Xcode created
7. Drag all the files from this repository into the Xcode project navigator (check "Copy items if needed")
8. Make sure the target membership is checked for all files
9. In Info tab (or Info.plist), add the camera usage description if not already present:
   - Key: `Privacy - Camera Usage Description`
   - Value: `I Am Watching You needs the camera to observe and describe your surroundings.`
10. Run on a **real iPhone**

## Using the app

1. Tap the key icon and paste your OpenAI API key
2. Point the camera at something
3. Press the red eye button
4. The app will describe what it sees and speak it out loud

**Never commit your real API key to GitHub.**

## Project Structure

```
├── README.md
├── LICENSE
├── .gitignore
├── IAmWatchingYouApp.swift
├── ContentView.swift
├── Info.plist
├── Models/
│   └── AppState.swift
├── Services/
│   ├── CameraService.swift
│   ├── VisionService.swift
│   └── SpeechService.swift
└── Views/
    ├── CameraView.swift
    └── DescriptionView.swift
```

## License

MIT License
