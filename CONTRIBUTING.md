<!--
SPDX-FileCopyrightText: 2025 Uwe Fechner
SPDX-License-Identifier: MIT
-->

# Contribution Guidelines for KiteUtils.jl

Welcome to the KiteUtils.jl community! We appreciate your interest in contributing. These guidelines will help you get started and ensure your contributions are effective and welcome.
## How to Contribute

1. Choose Your Contribution Type

-    Code: Fix bugs, add features, or improve performance.

-    Documentation: Write or update documentation, docstrings, tutorials, or examples.

-    Tests: Add new tests or improve existing ones.

-    Bug Reports: File issues for bugs you find.

-    Feature Requests: Suggest new features or improvements.

### License
By contributing code to KiteUtils.jl, you are agreeing to release that code under the [MIT License](https://github.com/OpenSourceAWE/KiteUtils.jl/blob/main/LICENSE) 

2. Get Set Up

- Install Julia: Make sure you have a recent version of Julia installed. Use `juliaup` to install Julia.

- Fork the Repository: Click "Fork" on the KiteUtils.jl GitHub page.

- Clone Your Fork: Clone your fork to your local machine.

- Set Up the Development Environment


3. Make Your Changes

- Follow Code Style: Adhere to the [style conventions](https://ufechner7.github.io/KiteModels.jl/stable/advanced/#Coding-style) used in the project.

- Document Your Code: Add or update docstrings and documentation as needed.

- Write Tests: Include tests for new features or bug fixes.

4. Submit Your Contribution

- Commit Your Changes: Use clear, descriptive commit messages.

- Push to Your Fork: Push your branch to your GitHub fork.

- Open a Pull Request (PR): Submit a PR to the main KiteUtils.jl repository.

- Describe Your Changes: Clearly explain what you changed and why.

5. Review and Improve

- Respond to Feedback: Be open to suggestions and make requested changes.

- Stay Engaged: Monitor your PR for comments and questions.

## Code Style and Quality

- Follow Julia conventions: Use consistent naming, indentation, and style.

- Document Your Work: Ensure all new code is well-documented.

- Test Thoroughly: Make sure your changes do not break existing functionality.

## Reporting Issues

- Check for Duplicates: Search existing issues before reporting a new one.

- Provide Details: Include steps to reproduce, error messages, and relevant environment details.

## Getting Help

- Community Support: Ask questions on the Julia Discourse forum or the KiteUtils.jl issue tracker.

- Code of Conduct: Be respectful and inclusive in all interactions.

If you want to contribute a new kite model, you can get chat support via Signal. Just create an issue explaining your idea first.

## Additional Resources

- GitHub Guide: Learn how to use Git and GitHub for contributions.

 - Julia Documentation: Read the Julia contributor guide for more tips.


## Releases
Before creating a new release, please check
- that all tests pass
- that all examples are part of the menu
- that all examples in the menu work
- execute `meld README.md docs/src/index.md` and make sure both are up-to-date 
- test the installation on Linux for both Julia 1.10 and the latest stable Julia version
- test the installation on Windows after deleting the .julia folder
- run `pipx run reuse lint` and make sure all files have a license attached; 
  See: https://reuse.readthedocs.io/en/latest/readme.html
