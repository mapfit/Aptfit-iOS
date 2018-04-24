//
//  Listing.swift
//  Aptfit-iOS
//
//  Created by Zain N. on 4/24/18.
//  Copyright © 2018 Mapfit. All rights reserved.
//

import Foundation

struct Listing : Hashable {
    var name: String
    var imageUrl: String
    var price: String
    var address: String
    var neighborhood: String
    var bedroomCount: Int
    var bathroomCount: Int
    var area: Int
    var availableDate: String
    
    static func ==(lhs: Listing, rhs: Listing) -> Bool {
        return lhs.address == rhs.address
    }
}
