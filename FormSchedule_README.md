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
    └── HomeFormScheduleView.swift         # Main container view
```

## Data Flow

1. **Initialization**: ViewController → ViewModel with package data
2. **View Loading**: ViewModel builds sections → ViewController displays
3. **Date Selection**: User taps → Calendar popup → ViewModel updates → UI refreshes
4. **Participant Selection**: User taps → Validation-based picker → ViewModel updates → UI refreshes
5. **Checkout**: ViewModel validates → API call → Navigation to checkout

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
- ✅ Comprehensive code documentation

## Testing
Build tested successfully with Xcode. All features working as expected with proper validation and user feedback.