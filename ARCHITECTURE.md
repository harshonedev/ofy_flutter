# Project Architecture

## Overview
This project follows Clean Architecture principles with BLoC (Business Logic Component) pattern for state management and GetIt for dependency injection. The structure is organized into layers that separate concerns and increase modularity.

## Directory Structure

```
lib/
  ├── core/                          # Core functionality used across features
  │   ├── constants/                 # App-wide constants
  │   ├── di/                        # Dependency injection setup
  │   ├── error/                     # Error handling
  │   ├── theme/                     # App theming
  │   └── usecases/                  # Base usecase classes
  │
  ├── features/                      # App features
  │   ├── chat/                      # Chat feature
  │   │   ├── data/                  # Data layer
  │   │   │   ├── datasources/       # Local and remote data sources
  │   │   │   ├── models/            # Data models
  │   │   │   └── repositories/      # Repository implementations
  │   │   │
  │   │   ├── domain/                # Domain layer (business logic)
  │   │   │   ├── entities/          # Business entities
  │   │   │   ├── repositories/      # Repository interfaces
  │   │   │   └── usecases/          # Business use cases
  │   │   │
  │   │   └── presentation/          # Presentation layer
  │   │       ├── bloc/              # BLoC components
  │   │       ├── pages/             # UI pages/screens
  │   │       └── widgets/           # Reusable UI components
  │   │
  │   ├── model_picker/              # Model selection feature
  │   │   ├── ...                    # Same structure as chat feature
  │   │
  │   └── settings/                  # Settings feature
  │       ├── ...                    # Same structure as chat feature
  │
  └── main.dart                      # App entry point
```

## Architecture Layers

### Data Layer
- **Models**: Data representations that extend domain entities with data-specific functionality
- **Data Sources**: Interfaces and implementations for accessing data sources (local storage, API)
- **Repositories**: Implementations of domain repository interfaces

### Domain Layer
- **Entities**: Core business models
- **Repositories**: Abstract interfaces defining data operations
- **Use Cases**: Application-specific business rules

### Presentation Layer
- **BLoC**: Manages state and business logic for UI components
- **Pages**: Full screens in the application
- **Widgets**: Reusable UI components

## Dependency Injection
GetIt is used as a service locator to provide instances of repositories, use cases, and BLoCs throughout the app. This simplifies dependency management and enables better testability.

## State Management
The BLoC pattern separates business logic from UI components:
- **Events**: Trigger state changes (user actions)
- **States**: Represent UI states
- **BLoC**: Processes events and emits states

## Error Handling
The application uses the Either type from the dartz package to handle failures in a functional way. Domain failures are propagated up to the presentation layer where they're handled appropriately.