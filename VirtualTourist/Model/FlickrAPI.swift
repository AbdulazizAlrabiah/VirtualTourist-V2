//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by aziz on 18/06/2019.
//  Copyright © 2019 Aziz. All rights reserved.
//

import Foundation
import UIKit

class FlickrAPI {
    
    static var arrayOfURLs: [String] = []
    
    struct Endpoint {
        static let flickrBaseURL: String = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=a996bd52a219a6eadaab624e2abd78b7"
        
        static func fillURL(random: Int, lat: Double, long: Double) -> String {
            return flickrBaseURL +  "&lat=\(lat)&lon=\(long)&radius=20&per_page=15&page=\(random)&format=json&nojsoncallback=1"
        }
    }
    
    class func request<T: Codable>(url: String, completion: @escaping (T) -> Void, errorr: @escaping (String) -> Void) {
        
        let request = URLRequest(url: URL(string: url)!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    errorr("Connection error please try again")
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    errorr("Connection error please try again")
                }
                return
            }
            do {
                let object = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(object)
                }
            } catch {
                DispatchQueue.main.async {
                    errorr("Error please try again later")
                }
            }
            }.resume()
    }
    
    class func getImages(lat: Double, long: Double, completion: @escaping ([String]) -> Void, errorOccured: @escaping (String) -> Void) {
        
        let random = Int.random(in: 1...10)
        
        request(url: Endpoint.fillURL(random: random, lat: lat, long: long), completion: { (results: PhotoAlbumResponse) in
            
            fillURLsArray(photos: results.photos.photo)
            
            DispatchQueue.main.async {
                completion(self.arrayOfURLs)
            }
        }, errorr: { (error) in
            errorOccured(error)
        })
        arrayOfURLs.removeAll()
    }
    
    class func fillURLsArray(photos: [PhotoAlbumArrayResponse]) {
        
        for (index, photo) in photos.enumerated() {
            arrayOfURLs.append("https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg")
        }
    }
    
    class func getData(url: String, completion: @escaping (Data) -> Void) {
        
        DispatchQueue.main.async {
            let imageData =  try? Data(contentsOf: URL(string: url)!)
            completion(imageData!)
        }
    }
}
