//
//  PhotoAlbumArrayResponse.swift
//  VirtualTourist
//
//  Created by aziz on 21/06/2019.
//  Copyright © 2019 Aziz. All rights reserved.
//

import Foundation

struct PhotoAlbumArrayResponse: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
}
