# 🍽️ Gram Restaurants - Sellers App

A comprehensive Flutter mobile application for restaurant sellers to manage their business operations, including menu management, order processing, earnings tracking, and more.

## 📱 Overview

The Gram Restaurants Sellers App is a feature-rich mobile application built with Flutter that enables restaurant owners and sellers to efficiently manage their business operations. The app provides a complete solution for menu management, order processing, earnings tracking, and business analytics.

## ✨ Key Features

### 🔐 Authentication & User Management
- **Secure Login/Signup** - Firebase Authentication integration
- **Profile Management** - User profile with image upload
- **Location Services** - GPS-based location tracking for delivery areas
- **Permission Handling** - Location and camera permissions

### 📋 Menu Management
- **Menu Creation** - Create and manage multiple menu categories
- **Item Management** - Add, edit, and organize food items
- **Image Upload** - High-quality food photography support
- **Price Management** - Dynamic pricing with tax calculations
- **Menu Categories** - Organize items by categories

### 📦 Order Management
- **Real-time Orders** - Live order notifications and updates
- **Order Details** - Comprehensive order information
- **Order History** - Complete order tracking and history
- **Order Status** - Track order progress and status updates

### 💰 Earnings & Analytics
- **Earnings Dashboard** - Visual charts and analytics
- **Period-based Reports** - Daily, weekly, monthly reports
- **Tax Calculations** - Automatic tax computation
- **Performance Metrics** - Business performance insights

### 🗺️ Location Services
- **GPS Integration** - Accurate location tracking
- **Address Management** - Store location management
- **Delivery Areas** - Service area configuration

## 🛠️ Technical Stack

### Frontend
- **Flutter** - Cross-platform mobile development
- **Dart** - Programming language
- **Material Design 3** - Modern UI/UX design

### Backend & Services
- **Firebase Core** - Backend infrastructure
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - File storage for images
- **Shared Preferences** - Local data storage

### Key Dependencies
```yaml
dependencies:
  flutter: sdk
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  firebase_storage: ^latest
  geolocator: ^latest
  geocoding: ^latest
  image_picker: ^latest
  permission_handler: ^latest
  shared_preferences: ^latest
  fl_chart: ^0.68.0
  intl: ^latest
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase project setup
- Google Services configuration

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/sellers_app.git
   cd sellers_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Create a Firebase project
   - Add your `google-services.json` file to `android/app/`
   - Configure Firebase Authentication, Firestore, and Storage

4. **Run the application**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── global/
│   ├── global_instances.dart    # Global service instances
│   └── global_vars.dart         # Global variables
├── model/
│   ├── address.dart             # Address model
│   ├── earning.dart             # Earnings model
│   ├── item.dart                # Menu item model
│   └── menu.dart                # Menu model
├── services/
│   ├── earnings_service.dart     # Earnings business logic
│   └── order_sync_service.dart  # Order synchronization
├── view/
│   ├── authScreens/             # Authentication screens
│   ├── mainScreens/             # Main application screens
│   │   ├── items/               # Item management
│   │   └── menus/               # Menu management
│   ├── splashScreen/            # App splash screen
│   └── widgets/                 # Reusable UI components
├── viewModel/                   # Business logic and state management
└── main.dart                    # Application entry point
```

## 🎯 Main Screens

### Authentication
- **Splash Screen** - App initialization and loading
- **Sign In/Sign Up** - User authentication
- **Profile Setup** - User profile configuration

### Main Dashboard
- **Home Screen** - Menu overview and management
- **Menu Management** - Create and edit menus
- **Item Management** - Add and manage food items
- **Order Processing** - Handle incoming orders
- **Earnings Dashboard** - Financial analytics and reports

## 🔧 Configuration

### Firebase Setup
1. Create a Firebase project
2. Enable Authentication, Firestore, and Storage
3. Add your app to the Firebase project
4. Download and add `google-services.json`

### Environment Variables
- Configure Firebase project settings
- Set up API keys and configuration
- Configure location services

## 📱 Platform Support

- **Android** - Full support with native features
- **iOS** - Full support with native features
- **Cross-platform** - Single codebase for both platforms

## 🔒 Security Features

- **Firebase Authentication** - Secure user authentication
- **Data Encryption** - Encrypted data transmission
- **Permission Management** - Granular permission handling
- **Secure Storage** - Safe local data storage

## 📊 Analytics & Reporting

- **Earnings Tracking** - Comprehensive financial reporting
- **Order Analytics** - Order performance metrics
- **Business Insights** - Data-driven business decisions
- **Visual Charts** - Interactive data visualization

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

## 🚀 Future Enhancements

- [ ] Push notifications
- [ ] Advanced analytics
- [ ] Multi-language support
- [ ] Offline mode
- [ ] Advanced reporting features
- [ ] Integration with payment gateways

---

**Built with ❤️ using Flutter**
