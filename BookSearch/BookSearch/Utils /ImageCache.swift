//
//  ImageCache.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 15/08/2024.
//

import Foundation
import UIKit
import Combine
import SwiftUI

class ImageCache {
    static let shared = ImageCache()
    
    private var cache = NSCache<NSURL, UIImage>()
    
    func getImage(forKey key: NSURL) -> UIImage? {
        return cache.object(forKey: key)
    }
    
    func setImage(_ image: UIImage, forKey key: NSURL) {
        cache.setObject(image, forKey: key)
    }
}

class AsyncImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private var cancellable: AnyCancellable?
    
    func loadImage(from url: URL) {
        let nsUrl = url as NSURL
        
        if let cachedImage = ImageCache.shared.getImage(forKey: nsUrl) {
            self.image = cachedImage
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self = self, let image = image else { return }
                ImageCache.shared.setImage(image, forKey: nsUrl)
                self.image = image
            }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}
