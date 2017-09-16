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

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    var networkErrorLabel: UILabel!
    
    var movies: [[String: Any]] = [[String: Any]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
        tableView.delegate = self
        
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
        fetchData(successCallBack: {
            
            (dictionary) in
                self.movies = dictionary["results"] as! [[String: Any]]
                self.tableView.reloadData()
                self.networkErrorLabel.isHidden = true
            
        }, errorCallBack: {
        
            (error) in
                self.networkErrorLabel.isHidden = false
            
        });
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl){
       
        fetchData(successCallBack: {
            
            (dictionary) in
            self.movies = dictionary["results"] as! [[String: Any]]
            self.tableView.reloadData()
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
        let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
        let cell = tableView.cellForRow(at: indexPath) as! MovieCell
        
        dvc.image = cell.posterView.image
        dvc.movieTitle = cell.titleLabel.text
        dvc.movieOverview = cell.overviewLabel.text
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return movies.count
    }

    //UITableViewDataSource: to be implemented
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = MovieCell() - too expensive to create a new object for every new cell
        let cell  = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell
        
        let movie = movies[indexPath.section]
        let title = movie["title"] as? String
        let overview = movie["overview"] as? String
        var posterUrl: URL!
        if let path = movie["poster_path"] as? String {
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            posterUrl = URL(string: baseUrl + path)
        }
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWith(posterUrl)
    
        return cell
    }
    
    //fetch data
    func fetchData(successCallBack: @escaping ([String: Any]) -> (), errorCallBack: ((Error?) -> ())?) {
        let url = URL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=aad8a3c8529bf64b06e59e328c0f8c2b")
        
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

}

