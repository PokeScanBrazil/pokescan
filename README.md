# PokéScan (iOS)

PokéScan is an iOS app that identifies Pokémon TCG cards with the iPhone camera. Point the camera at a card and the app reads the card name and collection number (e.g. `025/165`) on-device with Apple's Vision text recognition, then asks the [PokéScan backend](https://github.com/PokeScanBrazil/pokescan-backend) for the card's details: image, edition, rarity and type.

It is a personal side project, built for collectors and players in Brazil who want to catalog their cards quickly instead of typing them in one by one.

> Status: early development. Camera preview, card region overlay, auto-focus, on-device text reading and the network layer are in place. See [ROADMAP.md](ROADMAP.md) for what comes next.

## Features

- Live camera preview with a card-shaped scanning overlay
- Auto-focus control tuned for reading small card text
- On-device OCR with `VNRecognizeTextRequest` (no image leaves the phone)
- Extraction of the card name and collection number from the recognized text
- Typed networking layer (`Endpoint`, `NetworkClient`, `NetworkError`) with unit tests
- MVVM structure with SwiftUI

## Built with

- Swift, SwiftUI, AVFoundation, Vision
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) for project generation (`project.yml`)
- [SwiftLint](https://github.com/realm/SwiftLint)
- Make for common tasks
- iOS 15+

## Project structure

```
Sources/
  Scenes/CardReader/   # camera screen: View, components, ViewModel, LiveTextReader
  Networking/          # Core (client, endpoint, errors), Models, Services
  Helpers/             # CameraManager (AVFoundation session, focus)
  Extensions/
PokéScanTests/         # unit tests
PokéScanUITests/       # UI tests
Resources/             # Info.plist, .swiftlint.yml
project.yml            # XcodeGen spec
Makefile
```

## Running locally

Requirements: Xcode 15+, Homebrew.

```bash
brew install xcodegen swiftlint
git clone https://github.com/PokeScanBrazil/pokescan.git
cd pokescan
make gen      # generates PokéScan.xcodeproj from project.yml
make build    # builds for the iPhone 16 simulator
make lint     # runs SwiftLint
```

The camera only works on a real device, so run the app from Xcode on an iPhone to scan cards.

The app talks to the backend at `http://localhost:3000` by default (see `Sources/Networking/Core/Endpoint.swift`). Start the [backend](https://github.com/PokeScanBrazil/pokescan-backend) with Docker first.

## Contributing

Issues and suggestions are welcome. The planned work is listed in [ROADMAP.md](ROADMAP.md).

## License

[MIT](LICENSE) © João Guilherme Chagas de Freitas
