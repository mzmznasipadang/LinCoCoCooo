//
//  HomeFormScheduleInputView.swift
//  Coco
//
//  Created by Jackie Leonardy on 23/07/25.
//

import SwiftUI

struct HomeFormScheduleInputView: View {
    @ObservedObject var calendarViewModel: HomeSearchBarViewModel
    @ObservedObject var paxInputViewModel: HomeSearchBarViewModel
    
    // Add new view models for additional fields
    @State private var selectedTime = "7.30"
    @State private var travelerName = ""
    @State private var travelerPhone = ""
    @State private var travelerEmail = ""
    @State private var showingTimePicker = false
    
    var actionButtonAction: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24.0) {
                // MARK: - Select Time Section
                VStack(alignment: .leading, spacing: 8.0) {
                    Text("Select Time")
                        .font(.jakartaSans(forTextStyle: .footnote, weight: .medium))
                        .foregroundStyle(Token.grayscale70.toColor())
                    
                    Button(action: {
                        showingTimePicker.toggle()
                    }) {
                        HStack {
                            Text(selectedTime)
                                .font(.jakartaSans(forTextStyle: .body, weight: .regular))
                                .foregroundStyle(Token.grayscale90.toColor())
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundStyle(Token.grayscale50.toColor())
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color(Token.mainColorPrimary), lineWidth: 1)  // Convert UIColor to Color
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color(Token.additionalColorsWhite))  // Convert UIColor to Color
                                )
                        )
                    }
                }
                
                // MARK: - Number of Participants Section
                VStack(alignment: .leading, spacing: 8.0) {
                    Text("Number of participants")
                        .font(.jakartaSans(forTextStyle: .footnote, weight: .medium))
                        .foregroundStyle(Token.grayscale70.toColor())
                    
                    HomeSearchBarView(viewModel: paxInputViewModel)
                    
                    HStack {
                        Spacer()
                        Text("Available Slots: 10")
                            .font(.jakartaSans(forTextStyle: .caption1, weight: .regular))
                            .foregroundStyle(Token.grayscale50.toColor())
                    }
                }
                
                // MARK: - Traveler Details Section
                VStack(alignment: .leading, spacing: 20.0) {
                    Text("Traveler details")
                        .font(.jakartaSans(forTextStyle: .headline, weight: .semibold))
                        .foregroundStyle(Token.grayscale90.toColor())
                    
                    // Name Field
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text("Name")
                            .font(.jakartaSans(forTextStyle: .footnote, weight: .medium))
                            .foregroundStyle(Token.grayscale70.toColor())
                        
                        CustomTextField(
                            text: $travelerName,
                            placeholder: "Type here..."
                        )
                    }
                    
                    // Phone Field
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text("Phone")
                            .font(.jakartaSans(forTextStyle: .footnote, weight: .medium))
                            .foregroundStyle(Token.grayscale70.toColor())
                        
                        CustomTextField(
                            text: $travelerPhone,
                            placeholder: "Type here...",
                            keyboardType: .phonePad
                        )
                    }
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text("Email")
                            .font(.jakartaSans(forTextStyle: .footnote, weight: .medium))
                            .foregroundStyle(Token.grayscale70.toColor())
                        
                        CustomTextField(
                            text: $travelerEmail,
                            placeholder: "Type here...",
                            keyboardType: .emailAddress
                        )
                    }
                }
                
                // Add some bottom padding before the button
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 27)
            .padding(.top, 16)
        }
        .sheet(isPresented: $showingTimePicker) {
            TimePickerSheet(selectedTime: $selectedTime)
        }
    }
}

// MARK: - Custom TextField Component
struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(.jakartaSans(forTextStyle: .body, weight: .regular))
            .foregroundStyle(Token.grayscale90.toColor())
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Token.grayscale10.toColor())
            )
            .keyboardType(keyboardType)
    }
}

// MARK: - Time Picker Sheet
struct TimePickerSheet: View {
    @Binding var selectedTime: String
    @Environment(\.dismiss) var dismiss
    
    let timeSlots = ["7.30", "8.00", "8.30", "9.00", "9.30", "10.00", "10.30", "11.00"]
    
    var body: some View {
        NavigationView {
            List(timeSlots, id: \.self) { time in
                Button(action: {
                    selectedTime = time
                    dismiss()
                }) {
                    HStack {
                        Text(time)
                            .font(.jakartaSans(forTextStyle: .body, weight: .regular))
                            .foregroundStyle(Token.grayscale90.toColor())
                        
                        Spacer()
                        
                        if selectedTime == time {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Token.mainColorPrimary.toColor())
                        }
                    }
                }
            }
            .navigationTitle("Select Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}






//import SwiftUI
//
//struct HomeFormScheduleInputView: View {
//    @ObservedObject var calendarViewModel: HomeSearchBarViewModel
//    @ObservedObject var paxInputViewModel: HomeSearchBarViewModel
//
//    var actionButtonAction: () -> Void
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16.0) {
//            VStack(alignment: .leading, spacing: 8.0) {
//                Text("Date Visit")
//                    .font(.jakartaSans(forTextStyle: .footnote, weight: .medium))
//                    .foregroundStyle(Token.grayscale70.toColor())
//
//                HomeSearchBarView(viewModel: calendarViewModel)
//            }
//
//            VStack(alignment: .leading, spacing: 8.0) {
//                Text("Number of People")
//                    .font(.jakartaSans(forTextStyle: .footnote, weight: .medium))
//                    .foregroundStyle(Token.grayscale70.toColor())
//                HomeSearchBarView(viewModel: paxInputViewModel)
//            }
//            
//            Spacer()
//
//            CocoButton(
//                action: actionButtonAction,
//                text: "Checkout",
//                style: .large,
//                type: .primary
//            )
//            .stretch()
//        }
//    }
//}
