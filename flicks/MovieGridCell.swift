//
//  MovieGridCell.swift
//  flicks
//
//  Created by Liqiang Ye on 9/16/17.
//  Copyright © 2017 Liqiang Ye. All rights reserved.
//

import UIKit

class MovieGridCell: UICollectionViewCell {
    @IBOutlet weak var gridImageView: UIImageView!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var overview: String!
}
