# Contributing to NotchApp

First off, thank you for considering contributing to NotchApp! It's people like you that make NotchApp such a great tool.

## Code of Conduct

By participating in this project, you are expected to uphold our Code of Conduct. Please be respectful and considerate in all interactions.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

-   **Use a clear and descriptive title**
-   **Describe the exact steps to reproduce the problem**
-   **Provide specific examples to demonstrate the steps**
-   **Describe the behavior you observed and what you expected to see**
-   **Include screenshots or animated GIFs if possible**
-   **Note your macOS version and NotchApp version**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

-   **Use a clear and descriptive title**
-   **Provide a detailed description of the suggested enhancement**
-   **Explain why this enhancement would be useful**
-   **List any examples of how it would work**

### Pull Requests

1. **Fork the repository** and create your branch from `main`:

    ```bash
    git checkout -b feature/amazing-feature
    ```

2. **Make your changes**:

    - Follow the existing code style
    - Write clear, concise commit messages
    - Add tests if applicable
    - Update documentation as needed

3. **Test your changes**:

    - Ensure the app builds successfully
    - Test all functionality you've modified
    - Check for any warnings or errors

4. **Commit your changes**:

    ```bash
    git commit -m "Add amazing feature"
    ```

5. **Push to your fork**:

    ```bash
    git push origin feature/amazing-feature
    ```

6. **Open a Pull Request** and fill out the template

## Development Setup

Please refer to [SETUP.md](SETUP.md) for detailed instructions on setting up your development environment.

### Quick Start

1. Clone the repository
2. Open `NotchApp.xcodeproj` in Xcode
3. Build and run (⌘R)

## Style Guidelines

### Swift Code Style

-   Use Swift naming conventions
-   Follow SwiftUI best practices
-   Keep functions focused and concise
-   Add comments for complex logic
-   Use meaningful variable and function names

### Commit Messages

-   Use the present tense ("Add feature" not "Added feature")
-   Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
-   Limit the first line to 72 characters or less
-   Reference issues and pull requests liberally after the first line

Example:

```
Add music visualization feature

- Implement AVAudioPlayer integration
- Add waveform visualization component
- Update UI for media playback controls

Fixes #123
```

## Project Structure

```
NotchApp/
├── Models/          # Data models
├── Views/           # SwiftUI views
├── ViewModels/      # View models and business logic
├── Persistence/     # Core Data persistence
└── Shared/          # Shared utilities and extensions
```

## Testing

-   Write unit tests for new functionality
-   Ensure existing tests pass
-   Test on multiple macOS versions if possible

## Documentation

-   Update README.md if needed
-   Add inline documentation for public APIs
-   Update ARCHITECTURE.md for significant changes
-   Keep VISUAL_GUIDE.md updated with UI changes

## Questions?

Feel free to open an issue with your question or reach out to the maintainers.

## Recognition

Contributors will be recognized in our README.md file. Thank you for your contributions!

---

Happy coding! 🚀
