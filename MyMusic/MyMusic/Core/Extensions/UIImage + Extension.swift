//
//  NSCache<NSURL, UIImage> + Extensions.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 09/08/2024.
//

import Foundation
import UIKit
import AsyncAlgorithms

extension UIImage {
    
    static func fetch(_ url: URL?, queued: QueuedTask) async -> UIImage? {
        guard let url else { return nil }
        let cache = AppCache.shared.imageCache
        if let image = cache.object(forKey: url.nsURL) {
            return image
        } else {
            let t = Task {
                try await URLSession.shared.data(from: url)
            }
            await queued.enqueue(t, nsURL: url.nsURL)
            let result = queued.result
            var ite = result.makeAsyncIterator()
            if let (nsURL, image) = await ite.next(),
               url.nsURL == nsURL {
                return image
            }
            return nil
        }
    }
}
import Combine

actor QueuedTask {

    typealias Tazk = Task<(Data, URLResponse), any Error>
    private let cache: NSCache<NSURL, UIImage>
    private let channel: AsyncChannel<(NSURL, Tazk)>
    let result: AsyncChannel<(NSURL, UIImage)>
    
    init() {
        self.cache = AppCache.shared.imageCache
        self.channel = .init()
        self.result = .init()
        Task {
            await monitor()
        }
    }
    
    func enqueue(_ t: Tazk, nsURL: NSURL) async {
        await channel.send((nsURL, t))
    }
    
    private func monitor() async {
        for await (url, t) in channel {
            let result = await t.result
            switch result {
            case .success(let data):
                let (img, _) = data
                if let image = UIImage(data: img) {
                    cache.setObject(image, forKey: url)
                    await self.result.send((url, image))
                }
            case .failure(let error as NSError):
                switch error.code {
                case -999:
                    print(error.userInfo, error.localizedDescription)
                default:
                    print(#function, error.code, error.userInfo)
                }
            }
        }
    }
}
