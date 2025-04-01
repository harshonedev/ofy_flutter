Below is an updated README file that documents your Flutter chat app using the `llama_cpp_cart` package for on‑device LLM inference. This version explains the project phase‑by‑phase—from project setup and model file browsing to chat integration and testing—while highlighting the transition from AubAI to `llama_cpp_cart`.

---

# Chat LLM App with llama_cpp_cart

A Flutter-based cross‑platform chat application that integrates on‑device generative AI for local inference of large language models (in GGUF format) using the [llama_cpp_cart](https://github.com/netdur/llama_cpp_dart) package. This project currently targets Android with plans for future iOS support.

> **Note:** This app lets the user browse for a custom GGUF model file from storage and then initiates a chat interface where user messages are processed by the locally running LLM.

# Integration (Code Example)
``` import 'package:llama_cpp_dart/llama_cpp_dart.dart';

void main() async {
  final loadCommand = LlamaLoad(
    path: "path/to/model.gguf",
    modelParams: ModelParams(),
    contextParams: ContextParams(),
    samplingParams: SamplerParams(),
    format: ChatMLFormat(),
  );

  final llamaParent = LlamaParent(loadCommand);
  await llamaParent.init();

  llamaParent.stream.listen((response) => print(response));
  llamaParent.sendPrompt("2 * 2 = ?");
} ```

```class ChatMLFormat extends PromptFormat {
  ChatMLFormat()
      : super(PromptFormatType.chatml,
            inputSequence: '<|im_start|>user',
            outputSequence: '<|im_start|>assistant',
            systemSequence: '<|im_start|>system',
            stopSequence: '<|im_end|>');

  String preparePrompt(String prompt,
      [String role = "user", bool assistant = true]) {
    prompt = '<|im_start|>$role\n$prompt\n<|im_end|>\n';
    if (assistant) {
      prompt += '<|im_start|>assistant\n';
    }
    return prompt;
  }
}```

## Table of Contents

- [Overview](#overview)
- [Phase 1: Project Setup](#phase-1-project-setup)
- [Phase 2: Model File Browsing](#phase-2-model-file-browsing)
- [Phase 3: Chat Interface Integration](#phase-3-chat-interface-integration)
- [Phase 4: Running the App](#phase-4-running-the-app)
- [Future Enhancements](#future-enhancements)
- [Dependencies](#dependencies)
- [License](#license)

## Overview

This project demonstrates a Flutter chat app that performs on‑device LLM inference by loading a user-selected GGUF model file using the `llama_cpp_cart` package. The app workflow is divided into several phases:

- **Project Setup:** Create the Flutter project and add necessary dependencies.
- **Model File Browsing:** Use a file picker to allow the user to select a GGUF model.
- **Chat Interface:** Load the selected model and start a chat session where messages are processed by the LLM.
- **Running and Testing:** Run the app on Android (with plans to extend to iOS later).

## Phase 1: Project Setup

1. **Create a Flutter Project:**  
   Run the following in your terminal:
   ```bash
   flutter create chat_llama_app
   cd chat_llama_app
   ```

2. **Add Dependencies:**  
   Update your `pubspec.yaml` to include:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     llama_cpp_cart: ^x.y.z    # Replace x.y.z with the latest version
     file_picker: ^5.2.2
   ```
   Then run:
   ```bash
   flutter pub get
   ```

3. **Asset Setup (Optional):**  
   If you have a default GGUF model, place it in an `assets/` folder and declare it in `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/model.gguf
   ```

## Phase 2: Model File Browsing

In this phase, we add a screen that allows the user to browse and select a GGUF model file using the `file_picker` package.

- **ModelPickerPage:**  
  - Implements file browsing with custom filtering for the `gguf` extension (without the dot).
  - On file selection, the app navigates to the Chat screen while passing the selected file path.

Example snippet:
```dart
Future<void> _pickModelFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['gguf'],
  );
  if (result != null) {
    setState(() {
      _modelFilePath = result.files.single.path;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(modelFilePath: _modelFilePath!),
      ),
    );
  }
}
```

## Phase 3: Chat Interface Integration

After the model file is selected, the Chat screen loads the model using `llama_cpp_cart` and provides a simple chat UI.

1. **Model Loading & Inference:**  
   - The Chat screen receives the selected GGUF model file path.
   - It calls the equivalent of AubAI’s inference function (e.g., `inferenceAsync` or similar) from `llama_cpp_cart` to load the model and generate responses.
   - Responses are appended to the chat log token-by-token via a callback.

2. **User Interaction:**  
   - A TextField collects user messages.
   - On send, the app updates the chat log and calls the inference function with the user’s prompt.

Example code in the ChatPage:
```dart
await inferenceAsync(
  modelPath: widget.modelFilePath,
  prompt: promptTemplate.buildPrompt(),
  onToken: (String token) {
    setState(() {
      _chatOutput += token;
    });
  },
);
```
*(Adjust the function name and parameters based on the `llama_cpp_cart` API.)*

## Phase 4: Running the App

1. **Testing on Android:**  
   - Connect your Android device or emulator.
   - Run the app using:
     ```bash
     flutter run
     ```
   - The app will open on the Model Picker screen. Select a GGUF model file, and then the Chat interface will load, allowing you to send messages and receive LLM-generated responses.

2. **Monitoring & Debugging:**  
   - Check the console output for any errors or crashes.
   - Use Flutter’s debugging tools and logs to fine-tune model parameters and UI updates.

## Future Enhancements

- **iOS Support:**  
  Cross-compile the native llama.cpp library for iOS and adjust platform-specific configurations.
- **UI Improvements:**  
  Enhance the chat UI with better message bubbles, avatars, and animations.
- **Advanced Settings:**  
  Allow users to adjust inference