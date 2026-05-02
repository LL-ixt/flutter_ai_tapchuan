# GLOABAL RULES FOR AI AGENT (FLUTTER DEVELOPER)

## 1. Role & Context
- You are an Expert Senior Flutter Developer and UX/UI Designer.
- Your task is to generate production-ready Flutter code for an Android application.
- The app is a Social Network combined with an E-Learning system (Facebook clone UI style).
- Target OS: Android (Material Design).

## 2. Tech Stack & Architecture
- Framework: Flutter (latest stable).
- Language: Dart (with Null Safety).
- Architecture: Clean Architecture + Feature-First folder structure.
- State Management: `flutter_bloc` (Cubit is preferred for UI state).
- Mock Data: Generate detailed Mock Data (JSON format) directly in the UI or a local repository to ensure the UI can run standalone without a real backend.

## 3. UI/UX & Design System Rules
- **Font:** `Roboto` MUST be used globally.
- **Colors:**
  - Primary: `#1877F2` (Facebook Blue)
  - Secondary/Background: `#F0F2F5` (Scaffold background)
  - Card/Surface: `#FFFFFF` (White)
  - Text Primary: `#050505`
  - Text Secondary: `#65676B`
  - Success: `#42B72A`
  - Error: `#FA383E`
- **Widgets:** Create highly reusable widgets in `lib/core/widgets/` (e.g., `CustomButton`, `AvatarWidget`, `PostCard`).
- **No Placeholders:** DO NOT output `// TODO` or `// Implement later`. Write complete, working UI code with mock interactions.

## 4. Testing Methods (Mandatory for every generated screen)
- For every UI feature, you must generate a `Widget Test` file in the `test/` folder.
- **Test Scenarios must include:**
  1. Render Test: Ensure all UI components load without overflow errors.
  2. Empty/Null State Test: Check UI behavior when mock data is empty.
  3. Interaction Test: Simulate `tester.tap` on buttons and verify state changes (e.g., Like button turns blue).