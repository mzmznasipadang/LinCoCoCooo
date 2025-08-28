# FormSchedule Module Documentation

## Overview
The FormSchedule module implements the booking form screen in the Coco travel app. This screen allows users to review package details, select dates, choose participant counts, and complete booking information before proceeding to checkout.

## Architecture
The module follows the **MVVM (Model-View-ViewModel)** pattern with delegate-based communication:

- **Model**: `ActivityDetailDataModel`, `BookingDetailSection`, presentation models
- **View**: `HomeFormScheduleViewController`, table view cells, UI components  
- **ViewModel**: `HomeFormScheduleViewModel`
- **Contracts**: Protocol definitions for loose coupling

## Key Features

### ✅ Date Selection
- Calendar popup for date selection
- Immediate UI update when date is selected
- Formatted date display (e.g., "22 August, 2025")

### ✅ Participant Validation
- Min/max participant constraints from API
- Validation-based selection popup
- Real-time validation on checkout
- Error handling for invalid counts

### ✅ Dynamic Sections
- Package information with image, price, description, duration
- Collapsible Trip Provider section
- Collapsible Itinerary timeline
- Form inputs (date & participants)
- Traveler details form

### ✅ Responsive UI
- Auto-sizing table view cells
- Smooth expand/collapse animations
- Immediate feedback on user interactions
- Proper keyboard handling

### ✅ Smart Checkout Experience  
- Collapsible price details sticky footer
- Shows total price when collapsed
- Expands to show full booking summary when fields are complete
- Smooth animations and intuitive interactions
- "Book Now" button only enabled when form is complete

## File Structure

```
FormSchedule/
├── HomeFormScheduleViewController.swift     # Main view controller
├── HomeFormScheduleViewModel.swift         # Business logic & state
├── HomeFormScheduleViewModelContract.swift # Protocol definitions
├── Models/
│   ├── BookingDetailPresentationModels.swift # Data models
│   └── BookingDetailDataTransformer.swift    # Data transformation
├── Cells/
│   ├── FormInputCell.swift                 # Date & participant inputs
│   ├── PackageInfoCell.swift              # Package details display
│   ├── SectionContainerCell.swift         # Trip provider & itinerary
│   └── TravelerDetailsCell.swift          # Contact information
└── Views/
    ├── HomeFormScheduleView.swift         # Main container view
    └── PriceDetailsView.swift             # Collapsible price details component
```

## Data Flow

1. **Initialization**: ViewController → ViewModel with package data
2. **View Loading**: ViewModel builds sections → ViewController displays
3. **Date Selection**: User taps → Calendar popup → ViewModel updates → UI refreshes
4. **Participant Selection**: User taps → Validation-based picker → ViewModel updates → UI refreshes
5. **Price Updates**: Any form change → ViewModel calculates price → Price details view updates
6. **Checkout**: User taps "Book Now" → ViewModel validates → API call → Navigation to checkout

## Key Components

### HomeFormScheduleViewModel
- Manages form state and validation
- Handles date formatting and participant constraints
- Coordinates API calls for booking creation
- Rebuilds table sections on data changes

### FormInputCell
- Custom date selection with calendar popup
- Participant count field with tap-to-select behavior
- Prevents keyboard for participant field
- Immediate visual feedback

### Validation System
- Pre-selection validation (only show valid ranges)
- Checkout validation (verify before API call)
- Package constraint enforcement
- User-friendly error messaging

### PriceDetailsView
- Collapsible sticky footer component
- Smart expand/collapse based on form completion
- Real-time price calculation and display
- Smooth animations and visual feedback
- Integrated "Book Now" action

## Usage

```swift
let viewModel = HomeFormScheduleViewModel(
    input: HomeFormScheduleViewModelInput(
        package: activityDetail,
        selectedPackageId: packageId
    )
)
let viewController = HomeFormScheduleViewController(viewModel: viewModel)
```

## Recent Improvements

- ✅ Fixed date selection UI update issue
- ✅ Implemented participant validation with API constraints
- ✅ Added immediate feedback for all user interactions
- ✅ Improved accessibility with proper tap handling
- ✅ Enhanced error handling and validation
- ✅ **NEW**: Implemented collapsible price details sticky footer
- ✅ **NEW**: Smart expand/collapse based on form completion
- ✅ **NEW**: Real-time price calculation and updates
- ✅ **NEW**: Phone and email validation with visual feedback
- ✅ **NEW**: Advanced keyboard handling and navigation
- ✅ **NEW**: Automatic scroll restoration and field navigation
- ✅ Comprehensive code documentation

## Validation System

### Phone & Email Validation
The traveler details form now includes comprehensive validation for contact information:

#### Features
- **Real-time Validation**: Fields validate on text change and when editing ends
- **Visual Feedback**: Invalid fields show red border and error messages
- **Smart Validation Rules**:
  - Phone: 10-15 digits, optional + prefix
  - Email: Standard RFC-compliant email format validation
- **Error Messages**: Clear, user-friendly validation messages
- **Data Integration**: Validated data flows to price details and checkout

#### Implementation Details
```swift
struct TravelerData {
    let name: String
    let phone: String
    let email: String
    
    var isValid: Bool {
        return !name.isEmpty && isValidPhone(phone) && isValidEmail(email)
    }
}
```

#### Usage
- **Delegate Pattern**: `TravelerDetailsCellDelegate` notifies ViewModel of changes
- **Live Updates**: Price details update immediately when traveler name is entered
- **Form State**: Validation state affects checkout button availability

## Keyboard Handling System

### Advanced Keyboard Navigation
Implemented comprehensive keyboard handling for optimal mobile form experience:

#### Features
- **Smart Content Adjustment**: Automatically adjusts table view insets when keyboard appears
- **Auto-scroll to Active Field**: Keeps active text field visible and centered
- **Return Key Navigation**: Seamless field-to-field navigation
- **Automatic Restoration**: Smooth scroll back to natural position when keyboard dismisses

#### Navigation Flow
1. **Name Field** → Press Return → **Phone Field**
2. **Phone Field** → Press Return → **Email Field** 
3. **Email Field** → Press Return → **Dismiss Keyboard**

#### Technical Implementation
```swift
// Keyboard show handling
@objc private func keyboardWillShow(_ notification: Notification) {
    let keyboardHeight = keyboardFrame.height
    let priceDetailsHeight = priceDetailsView?.frame.height ?? 0
    let newBottomInset = keyboardHeight + priceDetailsHeight
    
    UIView.animate(withDuration: animationDuration) {
        self.thisView.tableView.contentInset.bottom = newBottomInset
        self.scrollToKeepVisible(textField: activeField)
    }
}

// Return key navigation
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    switch textField {
    case nameTextField: phoneTextField.becomeFirstResponder()
    case phoneTextField: emailTextField.becomeFirstResponder()  
    case emailTextField: textField.resignFirstResponder()
    }
    return true
}
```

#### Keyboard Behavior
- **Appears**: Content scrolls up, active field stays visible
- **Navigation**: Return key moves through fields logically
- **Dismisses**: Content smoothly returns to optimal viewing position
- **Integration**: Works seamlessly with sticky price details footer

## Updated Architecture

### Enhanced Data Flow
```
TravelerDetailsCell → Validation → Delegate → ViewModel → PriceDetails
     ↓                    ↓            ↓         ↓           ↓
Text Input → Real-time Check → Notify Change → Update State → UI Refresh
```

### Key Components Updated

#### TravelerDetailsCell
- Added validation logic with visual feedback
- Implemented UITextFieldDelegate for return key handling
- Real-time error display with animated transitions
- Delegate pattern for data change notifications

#### HomeFormScheduleViewModel  
- Added `onTravelerDataChanged` method
- Integrated traveler data into price calculations
- Real-time price details updates with actual traveler name

#### HomeFormScheduleViewController
- Comprehensive keyboard notification handling
- Smart scroll position management
- Auto-restoration of natural scroll position
- First responder tracking and management

## Testing
Build tested successfully with Xcode. All features working as expected with:
- ✅ Phone and email validation with proper error feedback
- ✅ Smooth keyboard navigation between fields
- ✅ Automatic scroll restoration when keyboard dismisses
- ✅ Integration with existing price details and checkout flow
- ✅ Proper memory management and notification cleanup