//
//  FavoriteButtonView.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 15/08/2024.
//

import SwiftUI

struct FavoriteButton: View {
    @Binding var isSet: Bool
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
