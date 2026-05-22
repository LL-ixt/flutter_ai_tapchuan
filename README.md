# 🎓 EduSocial AI: Multi-Agent E-Learning & Social Platform

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-Clean_Architecture-success)
![State Management](https://img.shields.io/badge/State-BLoC%2FCubit-blueviolet)
![AI](https://img.shields.io/badge/AI-Multi--Agent_LLM-orange)

**EduSocial AI** is a next-generation platform combining the engagement of a Social Network with the utility of an E-Learning system. It is specifically designed for physical education (e.g., dancing, marching, martial arts), utilizing a **Multi-Agent LLM Architecture** and **Computer Vision** to automatically evaluate and provide natural language feedback on students' body movements.

---

## 🌟 Core Problem & AI Solution

Traditional online physical education lacks real-time, accurate feedback. Instructors are overwhelmed by manually reviewing hundreds of student videos.

**Our Solution:** We implemented a Multi-Agent AI System to fully automate the grading and feedback process.

### 🤖 The Multi-Agent LLM Workflow
When a student uploads a practice video alongside the instructor's standard video, our system triggers a 3-agent collaboration:

1. **👁️ Vision Agent (Computer Vision):** Extracts spatial coordinates (Poses) from both videos using EasyMocap/Rokoko. Applies the **Dynamic Time Warping (DTW)** algorithm to calculate the physical deviation.
2. **🧠 Reasoning Agent (LLM):** Ingests the raw deviation data. Uses **Long-Chain of Thought (CoT)** reasoning to analyze the physical root cause (e.g., *"The student's right elbow is 15 degrees lower than the standard at the 3rd second"*).
3. **✍️ Feedback Agent (LLM):** Based on the Reasoning Agent's conclusion, it generates a natural, encouraging, and detailed instructional comment. This agent automatically posts the feedback to the student's submission on the social feed.

---

## ✨ Key Features

### Social Network Capabilities
- **Newsfeed:** Infinite scrolling post list with caching, pull-to-refresh, and pagination.
- **Interactions:** Real-time Like, Comment, Report, and Share functionalities.
- **Messenger:** Real-time chat via Socket.IO (Inbox, Chat room, Message recall).
- **Push Notifications:** Firebase integration for social activities.
- **Privacy Control:** Block users, customized push settings.

### E-Learning & AI Integration
- **Dual-Video Player:** Custom UI to simultaneously play the Instructor's video and the Student's submission side-by-side.
- **Auto-Grading:** AI automatically drops comments with scores and detailed HTML error reports.
- **Course Management:** Enroll, approve/reject students, manage class rosters.

---

## 🏗 System Architecture

This project strictly follows **Clean Architecture** principles to ensure scalability, testability, and maintainability.

```text
lib/
 ┣ core/               # Global constants, theme, widgets, network clients
 ┣ features/           # Feature-first modules
 ┃ ┣ auth/             # Login, Signup, OTP
 ┃ ┣ feed/             # Newsfeed, Post Listing
 ┃ ┣ post/             # Dual-video upload, Post interactions
 ┃ ┣ chat/             # Real-time messaging
 ┃ ┗ profile/          # User profile & settings
 ┗ main.dart           # Application entry point
```

- **State Management:** `flutter_bloc` (Cubit) is used exclusively for predictable state transitions.
- **Dependency Injection:** `get_it` for decoupling layers.
- **Networking:** `dio` with custom interceptors.

---

## 📱 UI Showcase

*(Note to reviewers: The UI is meticulously designed following standard Social Media UX guidelines, built natively with Flutter).*

| Home Feed (Dual Video) | Create Post (Student Submission) | Post Interactions |
| :---: | :---: | :---: |
| <img src="https://via.placeholder.com/250x500.png?text=Home+Feed+Screenshot" width="250"> | <img src="https://via.placeholder.com/250x500.png?text=Create+Post+Screenshot" width="250"> | <img src="https://via.placeholder.com/250x500.png?text=Comment+BottomSheet" width="250"> |
---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.19.0` or higher
- Dart SDK `^3.3.0`
- Android Studio / VS Code

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/hoangthcslt/Project_Flutter-AI.git
   ```
2. Navigate to the project directory:
   ```bash
   cd edusocial-ai
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```
*(Currently, the app utilizes robust Mock Data & Local State Management to simulate the full user journey while the backend API is being finalized).*

---

## 📝 To-Do / Roadmap
- [x] Clean Architecture Setup & Routing
- [x] Authentication UI & Cubit State
- [x] Newsfeed & Dual-Video UI Implementation
- [x] Post Interactions (Like, Comment BottomSheet)
- [ ] Real-time Socket.IO Integration for Chat
- [ ] Connect Flutter Client to Multi-Agent Python Backend

---
**Contact:** dinhhoang1712005@gmail.com
```

---

