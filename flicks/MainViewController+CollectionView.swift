//
//  MainViewController+CollectionView.swift
//  flicks
//
//  Created by Liqiang Ye on 9/17/17.
//  Copyright © 2017 Liqiang Ye. All rights reserved.
//

import UIKit
import AFNetworking

extension MainViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieGridCell", for: indexPath) as! MovieGridCell
        
        let movie = filteredMovies[indexPath.row]

        var url: URL!
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let path = movie["poster_path"] as? String {

            url = URL(string: baseUrl + path)

        }
        
        cell.gridImageView.setImageWith(url)
    
        
        return cell
    }
    
}
