//
//  PhotoAlbumResponse.swift
//  VirtualTourist
//
//  Created by aziz on 21/06/2019.
//  Copyright © 2019 Aziz. All rights reserved.
//

import Foundation

struct PhotoAlbumResponse: Codable {
    let photos: InsidePhotos
}

struct InsidePhotos: Codable {
    let photo: [PhotoAlbumArrayResponse]
}
