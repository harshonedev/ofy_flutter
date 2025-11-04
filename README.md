<div align="center">
  <img src="assets/icon/ofy_logo.png" alt="Ofy Logo" width="200"/>
</div>

# Ofy - Offline AI Chat App

A Flutter-based cross-platform chat application that integrates on-device generative AI for local inference of large language models (in GGUF format) 

<div align="center">
  
  [![Download APK](https://img.shields.io/badge/Download-APK-green?style=for-the-badge&logo=android)](https://github.com/harshonedev/ofy_flutter/releases/latest)
  [![GitHub Release](https://img.shields.io/github/v/release/harshonedev/ofy_flutter?style=for-the-badge)](https://github.com/harshonedev/ofy_flutter/releases)
  [![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)
  
</div>

## Features

- Browse and select GGUF model files from your device
- Chat with the selected model locally (offline)
- Real-time token streaming for AI responses
- Clean and intuitive UI with Material 3 design
- BLoC architecture with GetIt dependency injection

## Screenshots

<div align="center">
  <img src="assets/screenshots/01.png" alt="Screenshot 1" width="200"/>
  <img src="assets/screenshots/02.png" alt="Screenshot 2" width="200"/>
  <img src="assets/screenshots/03.png" alt="Screenshot 3" width="200"/>
  <img src="assets/screenshots/04.png" alt="Screenshot 4" width="200"/>
  <img src="assets/screenshots/05.png" alt="Screenshot 5" width="200"/>
</div>

## 🚀 Getting Started

### For Users

1. **Download the APK** from the [latest release](https://github.com/harshonedev/ofy_flutter/releases/latest)
2. Install on your Android device
3. **Download a GGUF model** from:
   - [Hugging Face](https://huggingface.co/models?library=gguf)
   - [TheBloke's Models](https://huggingface.co/TheBloke)
4. Open Ofy and select your model file
5. Start chatting with AI locally!

### For Developers

1. Clone this repository
   ```bash
   git clone https://github.com/harshonedev/ofy_flutter.git
   cd ofy_flutter
   ```
2. Install dependencies
   ```bash
   flutter pub get
   ```
3. Run the app
   ```bash
   flutter run
   ```

## 📋 Requirements

- Flutter SDK ^3.7.2
- Dart SDK (comes with Flutter)
- A GGUF format model file
- **Android**: API level 23 (Android 6.0) or higher
- **Storage**: Sufficient space for model files (typically 2-8GB)
- **RAM**: 4GB+ recommended for optimal performance
- iOS support coming soon

## Dependencies

- flutter_bloc: ^9.1.0 (for state management)
- get_it: ^8.0.3 (for dependency injection)
- dartz: ^0.10.1 (for functional error handling)
- equatable: ^2.0.5 (for value comparisons)
- file_picker: ^10.0.0
- path_provider: ^2.1.1
- shared_preferences: ^2.5.3

## Project Architecture

This project follows Clean Architecture principles with BLoC pattern for state management and GetIt for dependency injection. See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed information about the project structure.

### Key Architecture Concepts

- **Clean Architecture**: Separation of concerns with layers (presentation, domain, data)
- **BLoC Pattern**: Business Logic Components for state management
- **Dependency Injection**: Using GetIt as service locator
- **Repository Pattern**: Abstracting data sources
- **Use Cases**: Encapsulating business logic operations

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### Ways to Contribute

- 🐛 **Report Bugs**: Open an issue describing the bug and how to reproduce it
- 💡 **Suggest Features**: Share your ideas for new features or improvements
- 📖 **Improve Documentation**: Help make our docs clearer and more comprehensive
- 🔧 **Submit Pull Requests**: Fix bugs or implement new features

### Development Workflow

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes** following our code style
4. **Test your changes** thoroughly
5. **Commit your changes**
   ```bash
   git commit -m "Add: amazing feature description"
   ```
6. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```
7. **Open a Pull Request** with a clear description of your changes

### Code Style Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide
- Use meaningful variable and function names
- Add comments for complex logic
- Write unit tests for new features
- Keep commits atomic and well-described

### Getting Help

- 💬 **Discussions**: [GitHub Discussions](https://github.com/harshonedev/ofy_flutter/discussions)
- 🐛 **Issues**: [GitHub Issues](https://github.com/harshonedev/ofy_flutter/issues)
- 📧 **Email**: For sensitive matters, reach out via email

## 🗺️ Roadmap

- [ ] iOS support
- [ ] Model management (download, delete, organize)
- [ ] Conversation history persistence
- [ ] Multiple chat sessions
- [ ] Model parameter customization (temperature, top-p, etc.)
- [ ] Voice input support
- [ ] Export/Import conversations
- [ ] Multi-language support

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- The open-source community for GGUF model format
- All contributors and testers who help improve Ofy

## 📞 Support

If you find this project helpful, please consider:
- ⭐ Starring the repository
- 🐛 Reporting bugs
- 💡 Suggesting new features
- 🤝 Contributing to the codebase

---
