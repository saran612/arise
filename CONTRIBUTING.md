# Contributing to Arise

First off, thank you for taking the time to contribute to Arise! Contributions from the community make this open-source project better for everyone.

By contributing to this project, you agree to abide by the terms of the MIT License under which this project is distributed, and you agree to follow the guidelines and rules outlined in this document.

---

## Table of Contents

1. [MIT License Agreement](#mit-license-agreement)
2. [Code of Conduct](#code-of-conduct)
3. [How to Contribute](#how-to-contribute)
    - [Reporting Bugs](#reporting-bugs)
    - [Suggesting Enhancements](#suggesting-enhancements)
    - [Pull Requests](#pull-requests)
4. [Development Guidelines](#development-guidelines)
5. [OSS Rules & Regulations](#oss-rules--regulations)

---

## MIT License Agreement

All contributions you submit to this repository will be licensed under the project's **MIT License**. By submitting a Pull Request, you certify that:
- The work is either your own original work, or you have the legal right to submit it under the MIT License.
- You understand and agree that your contributions will be public and freely reusable by anyone under the terms of the MIT License.

---

## Code of Conduct

We are committed to providing a welcoming, inclusive, and harassment-free environment for everyone. Please be respectful, constructive, and friendly in all communications, issues, and PR comments.

---

## How to Contribute

### Reporting Bugs

If you find a bug:
1. Search the existing Issues to make sure it hasn't already been reported.
2. If it is new, open a new Issue using the Bug Report template.
3. Provide a clear description, steps to reproduce, expected behavior, and screenshots or logs if possible.

### Suggesting Enhancements

We welcome feature ideas:
1. Check the existing Issues and Roadmap to see if the feature is already discussed.
2. Open an Issue with the prefix `[Feature Request]` explaining the value, proposed design, and how users will benefit.

### Pull Requests

Please follow these steps to submit your changes:
1. **Fork** the repository and create your branch from `main`.
    - Recommended branch naming: `feature/your-feature-name` or `bugfix/issue-id`.
2. **Setup environment** and ensure all dependencies build successfully.
3. **Commit your changes** with clear, descriptive commit messages matching standard conventions (e.g. `feat: add graph filters` or `fix: resolve date matching rollover`).
4. **Format and lint** your code before committing:
    ```bash
    flutter format .
    flutter analyze
    ```
5. **Write tests** if you are introducing new logic or fixing a bug. Ensure existing test suites pass successfully.
6. **Submit a Pull Request** (PR) targeting the `main` branch:
    - Reference any related issues in the description.
    - Provide screenshot/video walk-throughs for user interface changes.

---

## Development Guidelines

- **Dart & Flutter style**: Follow the official [Effective Dart guide](https://dart.dev/guides/language/effective-dart) for style, design, and formatting.
- **Maintainability**: Write clean, self-documenting code. Add comments to explain complex or non-obvious logic.
- **Performance**: Keep widget trees lightweight. Avoid heavy calculations or expensive builds inside `build()` methods.
- **Localization**: Keep strings externalized or organized so they can be easily translated.

---

## OSS Rules & Regulations

To maintain the quality, security, and integrity of Arise as an open-source project, contributors must adhere to the following rules:

1. **No Proprietary Code**: Never copy code from closed-source or proprietary software. All submissions must be original or compatible with the MIT license.
2. **Security First**: Do not commit secrets, API keys, credentials, or personal information. 
3. **Respect Maintainers**: Project maintainers have the final say on whether a contribution fits the product roadmap. Be open to feedback and requests for changes during PR reviews.
4. **No Malicious Content**: Code containing malware, backdoors, tracker tools, or unsolicited advertising will be rejected immediately, and the contributor will be blocked.
5. **Keep PRs Single-focused**: Ensure each pull request addresses a single issue or feature. Large, multi-topic PRs are difficult to review and will be requested to be split.

Thank you for contributing to Arise! 🚀
