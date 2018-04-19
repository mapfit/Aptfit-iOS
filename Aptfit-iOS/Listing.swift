//
//  Listing.swift
//  Aptfit-iOS
//
//  Created by Zain N. on 4/17/18.
//  Copyright © 2018 Mapfit. All rights reserved.
//

import Foundation
import UIKit

struct Listing {
    var uuid: NSUUID
    var address: String
    var bedrooms: Int
    var bathrooms: Int
    var squarefeet: Int
    var price: String
    var neighborhood: String
    var images: [UIImage]
    var availablilityDate: String
}

