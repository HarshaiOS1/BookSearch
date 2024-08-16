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

/// This class is used saving images cache to get images from cache
class ImageCache {
    static let shared = ImageCache()
    
    private var cache = NSCache<NSURL, UIImage>()
    
    ///Get image from cache using its url if present
    ///
    ///- Parameter url: Image url
    ///- Returns : UIImage from cache if present
    func getImage(forKey key: NSURL) -> UIImage? {
        return cache.object(forKey: key)
    }
    
    ///Set image into cache aganist its  url
    ///
    ///- Parameter url: Image url
    ///- Returns : Save image to cache
    func setImage(_ image: UIImage, forKey key: NSURL) {
        cache.setObject(image, forKey: key)
    }
}

/// This class gets images from url and publishes the image
class AsyncImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?
    
    ///load  image from url and save it into image cache
    ///
    ///- Parameter url: image url
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
    
    ///Cancel Image fetch request
    func cancel() {
        cancellable?.cancel()
    }
}
