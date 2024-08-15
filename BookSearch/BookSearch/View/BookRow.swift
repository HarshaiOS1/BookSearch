//
//  BookRow.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 15/08/2024.
//

import SwiftUI

struct BookRow: View {
    var book : BookEntity
    var body: some View {
        HStack {
            if let url = book.thumbnail {
                CustomImageView(url: URL(string: url), placeholder: Image.init(systemName: "photo.on.rectangle.angled"))
                    .frame(width: 100, height: 150)
                    .cornerRadius(5)
            }
            Spacer()
            VStack {
                Text(book.title ?? "")
                    .font(.headline)
                    .lineLimit(3)
                Divider()
                
                Text("\n Authors : \(String(describing: book.authors ?? "Unknown"))")
                    .font(.caption)
            }
            .padding(.leading, 5)
            .frame(maxWidth: 200, alignment: .leading)
            Spacer()
            if book.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .frame(width: 30, height: 30)
            } else {
                Image(systemName: "star")
                    .foregroundStyle(.gray)
                    .frame(width: 30, height: 30)
            }
        }
        .frame(height: 150)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
    
}
