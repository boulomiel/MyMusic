//
//  SDArtist.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 07/08/2024.
//

import Foundation
import SwiftData
import MusicKit

@Model
class SDData {
    
    #Unique<SDData>([\.itemID])
    var itemID: String
    var type: Int
    var creationDate: Date
    
    init(itemID: String, type: SDDataType) {
        self.itemID = itemID
        self.type = type.rawValue
        self.creationDate = Date.now
    }
    
    var typeValue: SDDataType {
        SDDataType(rawValue: type)!
    }
}


enum SDDataType: Int {
    case artist
    case album
    case song
}
