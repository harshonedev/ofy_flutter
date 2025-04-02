# LLM Chat App

A Flutter-based cross-platform chat application that integrates on-device generative AI for local inference of large language models (in GGUF format) using the [llama_cpp_dart](https://github.com/netdur/llama_cpp_dart) package.

## Features

- Browse and select GGUF model files from your device
- Chat with the selected model locally (offline)
- Real-time token streaming for AI responses
- Clean and intuitive UI with Material 3 design

## Getting Started

1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Launch the app on your device
4. Select a GGUF model file from your device
5. Start chatting with the AI!

## Requirements

- Flutter SDK ^3.7.2
- A GGUF format model file
- Android device (iOS support coming soon)

## Dependencies

- llama_cpp_dart: ^0.0.7
- file_picker: ^6.1.1
- provider: ^6.1.1
- path_provider: ^2.1.1

## Project Architecture

The app follows a clean architecture approach with:

- Core: Constants, theme, and utilities
- Features: Model picker and chat functionality
- Domain: Entities and services
- Presentation: UI and state management

## License

This project is licensed under the MIT License - see the LICENSE file for details.
