//
//  FavoriteButtonView.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 15/08/2024.
//

import SwiftUI

/// A view that represents a button for toggling a favorite state.
/// This button changes its appearance based on the `isSet` binding and performs an action when toggled.
/// The `onToggle` closure is called whenever the button is pressed.
struct FavoriteButton: View {
    /// A binding to a Boolean value indicating whether the button is in a "set" (favorite) state.
    @Binding var isSet: Bool
    /// A closure that is called when the button is toggled.
    var onToggle: () -> Void
    
    var body: some View {
        Button(action: {
            isSet.toggle()
            onToggle()
        }) {
            Image(systemName: isSet ? "star.fill" : "star")
                .foregroundColor(isSet ? .yellow : .gray)
                .padding()
        }
    }
}
