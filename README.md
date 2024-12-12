# Lift Logger 

Lift Logger is a SwiftUI-based iOS application designed for managing workout plans. It allows users to create multi-day workout routines by selecting muscles and exercises, then log their chosen exercises by day. This app integrates with an external API (via the `ApiHandler`) to fetch exercises for a chosen muscle group.

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Customization](#customization)
- [Future Enhancements](#future-enhancements)
- [License](#license)

## Features
- **Home Page:** 
  - Users can input their first and last name (currently just for display/testing).
  - Simple, minimal UI with background imagery.

- **Workout Creation:**
  - Select how many days (3 to 7) you want the plan to last.
  - Choose a specific day of the week to assign exercises to.
  - Pick a muscle group from a predefined list.
  - Fetch exercises from an API based on the selected muscle group.
  - Add exercises to your chosen day’s workout plan.

- **Workout Logging:**
  - Review the planned workout for each selected day.
  - See exercises grouped by day, with sample sets and reps (currently default values).

## Requirements
- **Platform:** iOS 16.0 or later
- **Language:** Swift 5+
- **Libraries/Frameworks:** 
  - SwiftUI for UI
  - Combine for `@ObservedObject` and state management

You will need Xcode 14+ (or compatible) to build and run the project on a simulator or device.
