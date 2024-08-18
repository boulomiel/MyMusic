//
//  Wrapper<Object>.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 08/08/2024.
//
import MusicKit

protocol WrapperProtocol {
    associatedtype Object
    var value: Object { get set }
}

protocol MusicCatalogResourceRequestWrapperProtocol {
    associatedtype MusicCatalogResourceRequest
}

class Wrapper<Object>: WrapperProtocol {
    var value: Object
    
    init(value: Object) {
        self.value = value
    }
}
