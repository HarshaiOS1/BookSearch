//
//  CustomImageView.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 15/08/2024.
//

import Foundation
import SwiftUI

struct CustomImageView: View {
    @StateObject private var loader = AsyncImageLoader()
    let url: URL?
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
