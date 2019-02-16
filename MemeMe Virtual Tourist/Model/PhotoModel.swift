//
//  PhotoModel.swift
//  MemeMe Virtual Tourist
//
//  Created by Hessa Mohamed on 05/02/2019.
//  Copyright © 2019 Hessa Mohamed. All rights reserved.
//

import Foundation

import Foundation

struct PhotosModel: Codable{
    let photos: Photos
}

struct Photos: Codable {
    let photo: [PhotoModel]
}

struct PhotoModel: Codable {
    
    let url: String?
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case url = "url_n"
        case title
    }
}
