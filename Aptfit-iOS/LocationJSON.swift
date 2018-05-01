//
//  LocationJSON.swift
//  Aptfit-iOS
//
//  Created by Zain N. on 4/25/18.
//  Copyright © 2018 Mapfit. All rights reserved.
//

import Foundation

struct LocationJson : Decodable {
    var type: String
    var features: [Features]
    
}
struct Features : Decodable {
    var type: String
    var properties: [String: String]
    var geometry: Geometry
}

struct Geometry: Decodable {
    var type : String
    var coordinates : [[[[Double]]]]
}
