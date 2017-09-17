//
//  MainViewController.swift
//  flicks
//
//  Created by Liqiang Ye on 9/12/17.
//  Copyright © 2017 Liqiang Ye. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var networkErrorLabel: UILabel!
    
    var movies: [[String: Any]] = [[String: Any]]()
    
    var filteredMovies: [[String: Any]] = [[String: Any]]()
    
    var apiKey: String!
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //collection view
        collectionView.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        //tableView.separatorColor = .black
        tableView.backgroundColor = UIColor(red: 1, green: 0.7137, blue: 0, alpha: 1.0)
        
        //customize navigation bar to add a segmented control
        let segmentedControl = UISegmentedControl(items: ["List", "Grid"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(changeMoviesView), for: .valueChanged)

        segmentedControl.sizeToFit()
        let segmentedButton = UIBarButtonItem(customView: segmentedControl)
        navigationItem.rightBarButtonItem = segmentedButton
        
        let homeNavigationButtonItem = UIBarButtonItem(title: "Home", style: UIBarButtonItemStyle.plain, target: self, action: #selector(returnToHome))
        navigationItem.leftBarButtonItem = homeNavigationButtonItem
        
        
        
        //initialize network error label
        
        networkErrorLabel = UILabel(frame: CGRect(x:0, y:0, width: self.view.frame.width, height: (self.view.frame.height * 0.07)))
        networkErrorLabel.textAlignment = .center
        networkErrorLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        networkErrorLabel.textColor = UIColor.white
        networkErrorLabel.font = UIFont.boldSystemFont(ofSize: 19)
        networkErrorLabel.text = "Network Error!"
        
        tableView.addSubview(networkErrorLabel)
        networkErrorLabel.isHidden = true
        
        //insert pull-to-refresh
        //1. initialize a UI refresh control
        let refreshControl = UIRefreshControl()
        
        //2. implment an action to update the list - see refreshControlAction
        
        //3. bind the action to the refresh control
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        
        //4. insert the refresh control into the list
        tableView.insertSubview(refreshControl, at: 0)
        
        //fetch data
        apiKey = "aad8a3c8529bf64b06e59e328c0f8c2b"
        fetchData(successCallBack: {
            
            (dictionary) in
                self.movies = dictionary["results"] as! [[String: Any]]
                //initialize filtered movies
                self.filteredMovies = self.movies
                self.tableView.reloadData()
                self.collectionView.reloadData()
                self.networkErrorLabel.isHidden = true
            
        }, errorCallBack: {
        
            (error) in
                self.networkErrorLabel.isHidden = false
            
        });
    }
    
    func changeMoviesView(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            tableView.isHidden = false
            collectionView.isHidden = true
        case 1:
            tableView.isHidden = true
            collectionView.isHidden = false
        default:
            tableView.isHidden = false
            collectionView.isHidden = true
        }
        
    }
    
    func returnToHome(sender: UIBarButtonItem) {
        
        filteredMovies = movies
        //reload tableView
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl){
       
        fetchData(successCallBack: {
            
            (dictionary) in
            self.movies = dictionary["results"] as! [[String: Any]]
            self.filteredMovies = self.movies
            self.tableView.reloadData()
            self.collectionView.reloadData()
            refreshControl.endRefreshing()
            self.networkErrorLabel.isHidden = true
            print("refresh completed")
            
        }, errorCallBack: {
            
            (error) in
        
            refreshControl.endRefreshing()
            self.networkErrorLabel.isHidden = false
            
        });
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let dvc = segue.destination as! MovieDetailsViewController
        
        
        var indexPath: IndexPath!
        
        //check sender and prepare next view accordingly
        if (sender is UITableViewCell) {
            
            indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
            let movieCell = tableView.cellForRow(at: indexPath) as! MovieCell
            
            dvc.image = movieCell.posterView.image
            dvc.movieTitle = movieCell.titleLabel.text
            dvc.movieOverview = movieCell.overviewLabel.text
        }else if (sender is UICollectionViewCell) {
            
            indexPath = collectionView.indexPath(for: sender as! UICollectionViewCell)!
            
            let movieGridCell = collectionView.cellForItem(at: indexPath) as! MovieGridCell
            
            dvc.image = movieGridCell.gridImageView.image
            dvc.movieTitle = movieGridCell.titleLabel.text
            dvc.movieOverview = movieGridCell.overview
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredMovies.count
    }

    //UITableViewDataSource: to be implemented
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = MovieCell() - too expensive to create a new object for every new cell
        let cell  = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell
        
        let movie = filteredMovies[indexPath.section]
        let title = movie["title"] as? String
        let overview = movie["overview"] as? String
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview

        //Loading a low resolution image followed by a high resolution image
        let lowResBaseUrl = "http://image.tmdb.org/t/p/w45"
        let highResBaseUrl = "http://image.tmdb.org/t/p/original"
    
        var lowResRequestUrl: URL!
        var highResRequestUrl: URL!

        if let path = movie["poster_path"] as? String {
            lowResRequestUrl = URL(string: lowResBaseUrl + path)
            highResRequestUrl = URL(string: highResBaseUrl + path)

        }
        
        let lowResRequest = URLRequest(url: lowResRequestUrl)
        let highResRequest = URLRequest(url: highResRequestUrl)
        
        //set lower res image first
        cell.posterView.setImageWith(lowResRequest, placeholderImage: nil, success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
            
            if smallImageResponse != nil {
                //initial alpha = 0 -> no transparency
                cell.posterView.alpha = 0.0
                
                //set the image
                cell.posterView.image = smallImage
                
                //fading in an image with animation
                print("Samll image was not cached, download it and fade it in")
                //setting alpha to full opacity
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    cell.posterView.alpha = 1.0}, completion: { (sucess) -> Void in
                        
                        //upon completion of displaying low res image, then get and display high res image
                        cell.posterView.setImageWith(highResRequest, placeholderImage: smallImage, success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                            
                            print("High image downloaded, replace small image with it")
                            cell.posterView.image = largeImage
                            
                        }, failure: { (imageRequest, imageResponse, image) -> Void in
                            
                            print("High Resolution Image not found; set it back to low res image")
                            cell.posterView.image = smallImage
                            
                        })

                        
                        
                    }
                
                )
            } else {
                print("Small image was cached, update it to high res image")
                //upon completion of displaying low res image, then get and display high res image
                cell.posterView.setImageWith(highResRequest, placeholderImage: nil, success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                    
                    if largeImageResponse != nil {
                        print("High res image was not cached, downloaded and set it")
                        cell.posterView.image = largeImage
                    } else {
                        print("High res image was cachd; set it to cached high res image")
                        cell.posterView.image = largeImage
                    } //can combin
                    
                }, failure: { (imageRequest, imageResponse, image) -> Void in
                        //no failure handling needed
                    print("Failure: Unable to get high resolution image, set it back to low res image")
                    cell.posterView.image = smallImage

                })
            }
        
        }, failure: { (imageRequest, imageResponse, image) -> Void in
            
                print("Image not found!")
        })
    
        return cell
    }
    
    //cell styling
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = UIColor(red: 1, green: 0.7137, blue: 0, alpha: 1.0)

        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell  = tableView.cellForRow(at: indexPath) as! MovieCell
        cell.selectionStyle = .none
    
    }
    
    //fetch data
    func fetchData(successCallBack: @escaping ([String: Any]) -> (), errorCallBack: ((Error?) -> ())?) {

        let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey!)")
        
        var request = URLRequest(url: url!)
        
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
        
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: {
            (dataOrNil, response, error) in
            
            // Hide HUD once the network request comes back (must be done on main UI thread)
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let error = error {
                               
                errorCallBack?(error)
                
            } else if let data = dataOrNil{
                
                    let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                
                    successCallBack(dictionary)
            }
        }
        );
        
        task.resume()
    }
    
    //search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filteredMovies = searchText.isEmpty ? movies : movies.filter {
            (item: [String : Any]) -> Bool in
            
                if let title = item["title"] as? String {
                    //String range api
                    return title.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
                } else {
                    return false
                }
            
        }
        
        //reload tableView
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    
    //show cancel button
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        self.searchBar.showsCancelButton = true

    }
    
    //dismiss input keyboard
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    
        self.searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
    }

    
}

