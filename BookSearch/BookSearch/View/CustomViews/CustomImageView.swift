//
//  CustomImageView.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 15/08/2024.
//

import Foundation
import SwiftUI

/// `CustomImageView` is designed to load images asynchronously and display a placeholder image
/// while the image is being fetched. It uses an `AsyncImageLoader` to handle the asynchronous
/// image loading process.
///
/// - Important:
///     The `url` property should be a valid URL pointing to the image you want to display. If
///     the `url` is `nil`, only the placeholder image will be shown.
struct CustomImageView: View {
    @StateObject private var loader = AsyncImageLoader()
    /// The URL of the image to be loaded asynchronously.
    let url: URL?
    /// The placeholder image to display while the actual image is being loaded.
    let placeholder: Image
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                placeholder
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .onAppear {
                        if url != nil {
                            loader.loadImage(from: url!)
                        }
                    }
                    .onDisappear {
                        loader.cancel()
                    }
            }
        }
    }
}
