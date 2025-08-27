# Coco - Travel Activity Booking App

A native iOS travel application that allows users to discover, book, and manage travel activities with an intuitive and modern interface.

## 📱 Project Overview

Coco is a comprehensive travel booking app built with Swift and UIKit, featuring activity discovery, detailed package information, booking management, and user profiles. The app follows modern iOS development patterns with MVVM architecture, coordinator pattern for navigation, and modular design.

## ✨ Features

### 🏠 Home & Discovery
- **Activity Search & Filtering**: Advanced search with location, price range, and category filters
- **Interactive Activity Cards**: Rich activity listings with images, ratings, and quick details  
- **Live Search Suggestions**: Real-time search suggestions and filtering
- **Top Destinations**: Featured destination recommendations

### 📋 Activity Details & Booking
- **Comprehensive Activity Details**: Full descriptions, itineraries, highlights, and package options
- **Smart Booking Form**: Date selection, participant validation, and traveler details with real-time validation
- **Package Comparison**: Multiple package options with detailed pricing and inclusions
- **Collapsible Price Details**: Interactive pricing breakdown with smooth animations

### 🧳 Trip Management
- **My Trips Dashboard**: View and manage all bookings in one place
- **Trip Details**: Complete booking information and status tracking
- **Booking History**: Organized trip history with filtering options

### 👤 Profile & Authentication
- **User Authentication**: Secure sign-in/sign-out functionality
- **Profile Management**: Personal information and preferences
- **User Settings**: App configuration and account management

## 🏗️ Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture with additional patterns:

- **Coordinator Pattern**: Centralized navigation management
- **Protocol-Oriented Programming**: Contracts for loose coupling
- **Delegate Pattern**: Component communication
- **Repository Pattern**: Data layer abstraction

### Key Architectural Components:
- **ViewModels**: Business logic and state management
- **Coordinators**: Navigation flow control
- **Network Layer**: RESTful API communication with proper error handling
- **Common Components**: Reusable UI components and utilities

## 📁 Project Structure

```
├── Coco/                           // Main app source code
│   ├── AppDelegate.swift           // App lifecycle setup
│   ├── SceneDelegate.swift         // UI scene management
│   ├── Assets.xcassets/            // Images, icons, and visual assets
│   ├── Common/                     // Shared utilities and components
│   │   ├── Components/             // Reusable UI components
│   │   │   ├── Button/            // Custom button implementations
│   │   │   ├── Calendar/          // Calendar picker component
│   │   │   └── InputTextField/    // Custom text field components
│   │   ├── Extensions/             // Swift/UIKit extensions
│   │   ├── Fonts/                 // Plus Jakarta Sans font family
│   │   └── Token/                 // Design system tokens
│   ├── Coordinator/                // Navigation coordination
│   │   ├── AppCoordinator.swift   // Main app coordinator
│   │   └── RootCoordinator.swift  // Root navigation coordinator
│   ├── Network/                    // API services and networking
│   │   ├── Config/                // API configuration and endpoints
│   │   ├── Fetcher/               // Network request handlers
│   │   └── Model/                 // Data models and responses
│   ├── Pages/                      // App features and screens
│   │   ├── Home/                  // Activity discovery and booking
│   │   │   ├── CollectionView/    // Activity listing interface
│   │   │   ├── Detail/            // Activity detail screens
│   │   │   ├── Filter/            // Search and filter functionality
│   │   │   ├── FormSchedule/      // Booking form implementation
│   │   │   └── Search/            // Search functionality
│   │   ├── MyTrip/                // Trip management and history
│   │   └── Profile/               // User profile and authentication
│   └── Secrets.plist              // API keys and sensitive configuration
└── CocoTests/                      // Unit tests and test utilities
    ├── Common/                     // Shared test utilities
    └── Home/                       // Home module tests with mocks
```

## 🛠️ Setup & Installation

### Prerequisites
- Xcode 14.0 or later
- iOS 16.0+ deployment target
- Swift 5.7+

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone [repository-url]
   cd LinCoCoCooo\ Claude
   ```

2. **Open in Xcode:**
   - Open `Coco.xcodeproj` in Xcode 14 or later

3. **Configure API Keys:**
   - Add your API keys to `Secrets.plist`
   - Ensure the file is not committed to version control

4. **Set the correct scheme:**
   - Select `Coco` scheme for the main app
   - Choose `CocoTests` for running unit tests

5. **Build & Run:**
   - Requires iOS 16.0+ (iOS 17+ recommended for optimal experience)
   - Run on a real device for best results (some features may require device capabilities)

## 🚀 Usage

### For Users:
1. **Discover Activities**: Browse and search for travel activities by location and preferences
2. **View Details**: Tap any activity to see comprehensive details, packages, and itineraries
3. **Make Bookings**: Select dates, participants, and complete traveler information
4. **Manage Trips**: View and manage all your bookings in the My Trip section
5. **Profile Management**: Sign in to access personalized features and booking history

### For Developers:
- Each module follows consistent MVVM patterns
- Use coordinators for navigation between screens
- Extend common components for UI consistency
- Follow the existing network layer patterns for API integration

## 🧪 Testing

The project includes comprehensive unit tests:

```bash
# Run all tests
⌘ + U in Xcode

# Run specific test suites
- Home module tests with mock data
- Network layer tests
- ViewModel unit tests
```

## 🎨 Design System

- **Typography**: Plus Jakarta Sans font family with defined weights
- **Color Tokens**: Centralized color system with semantic naming
- **Components**: Reusable UI components following iOS Human Interface Guidelines
- **Icons**: Vector-based icons with consistent styling

## 🤝 Contributing

Contributions are welcome! To contribute:

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow the existing code style and architecture patterns
4. Add tests for new functionality
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Guidelines:
- Follow MVVM architecture patterns
- Use coordinators for navigation
- Write unit tests for business logic
- Follow iOS Human Interface Guidelines
- Ensure code is well-documented

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- **Team**: Built with dedication by the Coco development team
- **Design**: Modern iOS interface following Apple's design principles
- **Architecture**: Clean architecture patterns for maintainable code

## 📬 Support

For questions, bug reports, or feature requests:
- Open an issue in this repository
- Contact the development team
- Check the FormSchedule_README.md for detailed module documentation

---

**Built with ❤️ for travelers who love seamless booking experiences**