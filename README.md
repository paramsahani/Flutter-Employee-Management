# Flutter Employee Management App

##  Overview
This is a Flutter-based Employee Management Application developed as part of an assignment.  
The app supports authentication, employee CRUD operations, API integration, offline storage, and responsive UI.

---

##  Features

###  Authentication
- Signup & Login screens  
- Form validation  
- Local session management using SharedPreferences  

###  Employee Module
- Employee List (Name, Email, Phone, Role)  
- Add Employee  
- Edit Employee  
- Delete Employee  

###  API Integration
- Integrated with ReqRes API  
- Supports GET, POST, PUT, DELETE  

###  Offline Support
- Local storage using Hive  
- Offline-first architecture  
- Data persists even without internet  

###  Additional Features
- Search functionality  
- Pagination support  
- Dark mode support  
- Responsive UI (Mobile + Desktop)  

---

##  Project Structure

```bash
lib/
│
├── core/
│   ├── constants/
│   ├── utils/
│   └── theme/
│
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
│
├── presentation/
│   ├── providers/
│   ├── screens/
│   └── widgets/
│
└── main.dart
```

---

##  Setup Instructions

###  Clone Repository
```bash
git clone https://github.com/paramsahani/flutter-employee-management.git
cd flutter-employee-management
```

###  Install Dependencies
```bash
flutter pub get
```

###  Run App
```bash
flutter run
```

---

##  Architecture
- State Management: Provider  
- API Handling: Dio  
- Local Storage: Hive  
- Routing: GoRouter  

---

##  Error Handling
- Network errors handled using DioException  
- UI displays error messages via Provider state  
- Offline fallback implemented using local database  

---

##  Author
**Parmatma Sahani**

---

##  Notes
- API is used for demonstration only  
- UI always reflects local stored data  
- API runs in background for sync  

---

##  Conclusion
This app demonstrates clean architecture, offline-first design, and scalable Flutter practices.
