//
//  MovieDetailsViewController.swift
//  flicks
//
//  Created by Liqiang Ye on 9/14/17.
//  Copyright © 2017 Liqiang Ye. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    var  image: UIImage!
    
    @IBOutlet weak var movieInfoView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movieTitle: String!
    var movieOverview: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //initial alpha = 0 -> no transparency
        posterImageView.alpha = 0.0
        
        //set the image
        posterImageView.image = image
        
        //fading in an image with animation
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.posterImageView.alpha = 1.0}) //setting alpha to full opacity
        
        let contentWidth = scrollView.bounds.width
        let contentHeight = movieInfoView.frame.origin.y + movieInfoView.frame.size.height + 70
        scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
        
        
        titleLabel.text = movieTitle
        overviewLabel.text = movieOverview
        
        overviewLabel.sizeToFit()
        
           }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
