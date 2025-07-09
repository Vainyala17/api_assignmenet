# API Assignment - Personal Details App

## 📘 Project Overview

The **API Assignment - Personal Details App** is a mobile application developed using **Flutter**, aimed at demonstrating fundamental client-server communication by integrating with a mock REST API. It serves as a role-based user management system where users can register, log in, and access a personalized dashboard depending on their assigned role.

The app mimics a real-world authentication flow with form validations, secure local storage, and role-specific UI experiences. It is designed to help learners and developers understand how to perform HTTP requests, handle API responses, manage authentication tokens, and maintain user sessions using `SharedPreferences`.

## ✨ Key Features

- **🔐 User Registration:**
  - Allows new users to register by entering a mobile number, password, confirming their password, and selecting a role.
  - Input validation ensures correct format (e.g., mobile must start with 6/7/8/9 and be 10 digits).
  - Data is sent to a mock API (`json-server`) for backend simulation.

- **✅ Login Authentication:**
  - Users log in using their mobile number and password.
  - The app sends a GET request to validate credentials.
  - If authenticated, a token is generated and user details are stored locally.

- **🗂 Role-Based Home Screen:**
  - Displays a welcome message and the user's role and mobile number.
  - Drawer and app bar components are customized using the user role.

- **🧠 Persistent Storage:**
  - Uses `SharedPreferences` to securely store login session data such as token, mobile number, and role.
  - Automatically redirects logged-in users to the home screen on app restart.

- **💡 Clean UI/UX:**
  - Form validation with real-time feedback.
  - Password show/hide toggles.
  - Snackbars for status messages (e.g., registration success, login failure).
  - Loading indicators during API operations.

## 🛠️ Technical Stack

| Technology | Purpose |
|------------|---------|
| Flutter | Frontend framework for mobile UI |
| Dart | Programming language |
| json-server | Mock API backend to simulate database |
| HTTP package | For performing REST API calls |
| SharedPreferences | Persistent local storage (for auth) |
| Material Design | UI components and layout |

## 🚀 Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/api_assignment.git
   ```

2. Navigate to the project directory:
   ```bash
   cd api_assignment
   ```

3. Install the dependencies:
   ```bash
   flutter pub get
   ```

4. Start the mock API server:
   ```bash
   json-server --watch db.json
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## 📁 Folder Structure

```
api_assignment/
├── android/
├── ios/
├── lib/
│   ├── screens/
│   ├── services/
│   ├── widgets/
│   └── main.dart
├── test/
├── pubspec.yaml
└── README.md
```

## 📖 Usage Instructions

1. Launch the app on your mobile device or emulator.
2. Register a new user by filling in the required fields.
3. Log in using the registered mobile number and password.
4. Explore the role-based home screen and navigate through the app features.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any suggestions or improvements.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

### Key Markdown Elements Used:
- **Headers**: Use `#` for main titles and `##` for subsections
- **Lists**: Use `-` for bullet points and numbered lists for steps
- **Code Blocks**: Use triple backticks (```) for code snippets
- **Tables**: Use pipes (`|`) to create tables for structured data
- **Bold Text**: Use `**text**` for emphasis
- **Inline Code**: Use backticks for `code` elements
