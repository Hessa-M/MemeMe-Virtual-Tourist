//
//  FlickrAPI.swift
//  MemeMe Virtual Tourist
//
//  Created by Hessa Mohamed on 05/02/2019.
//  Copyright © 2019 Hessa Mohamed. All rights reserved.
//

import UIKit

class FlickrAPI {
    
    static func downloadPhotos(latitude: Double,longitude: Double, completion: @escaping (PhotosModel?, Bool, Error?)->()){
        
        let randomPage = arc4random_uniform(5) + 1;
        
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=0c98518328bf310a7e4fff2c22968f37&lat=\(latitude)&lon=\(longitude)&format=json&nojsoncallback=1&extras=url_n&page=\(randomPage)&per_page=21"
        
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                completion (nil, false, error)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                
                let statusCodeError = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
                
                completion (nil, false, statusCodeError)
                return
            }
            
            if statusCode >= 200  && statusCode < 300 {
                let photosModel = try! JSONDecoder().decode(PhotosModel.self, from: data!)
                
                completion (photosModel, true, nil)
            } else {
                completion (nil, false, nil)
            }
        }
        task.resume()
    }
    
    static func downloadImage(imageURL: String, completion: @escaping ( Data?, Bool, Error?)->()){
        
        let url = URL(string: imageURL)
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                completion (nil, false, error)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                
                let statusCodeError = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
                
                completion (nil, false, statusCodeError)
                return
            }
            
            if statusCode >= 200  && statusCode < 300 {
                
                completion (data, true, nil)
            } else {
                completion (nil, false, nil)
            }
            
        }
        task.resume()
    }
    
}
