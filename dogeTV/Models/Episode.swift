//
//  Episode.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Foundation

struct Episode: Decodable, Equatable {
    let title: String
    let url: String
}

struct VideoSource: Equatable, Hashable {
    let source: Int
    let isSelected: Bool
}
