# Nome padrão do workspace e projeto
WORKSPACE = PokeScan.xcworkspace
PROJECT = PokeScan.xcodeproj
SCHEME = PokéScan
CONFIG = Debug
DEVICE = "iPhone 16"

gen:
	xcodegen generate
	@echo "📦 Project generated with success"

clean:
	xcodebuild clean -project $(PROJECT) -scheme $(SCHEME)
	@echo "🧹 Clean build!"

build:
	xcodebuild build \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration $(CONFIG) \
		-destination 'platform=iOS Simulator,name=$(DEVICE)'
	@echo "🏗️  Build finished!"

lint:
	swiftlint
	@echo "🔍 SwiftLint finished!"

open:
	echo "Generating Xcode project using XcodeGen..."
	xcodegen
	echo "Done! Opening the .xcworkspace!"
	if [ -d "PokéScan.xcworkspace" ]; then \
		open PokéScan.xcworkspace; \
	else \
		open PokéScan.xcodeproj; \
	fi
