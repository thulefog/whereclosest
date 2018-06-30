//
//  QueryViewController.swift
//  whereclosest
//
//  Derived from SODA example:
//  https://github.com/socrata/soda-swift
//  Created by Hal Mueller on 6/2/17.
//  Copyright © 2017 Socrata. All rights reserved.
//
//  NOTE: refresh method needed to be exposed by @objc

import UIKit

class QueryViewController: UITableViewController {
    
    let client = SODAClient(domain: "data.sfgov.org", token: "vqcAOkEyVt8wTqGMbzRqv58yR")
    
    let cellId = "EventSummaryCell"
    
    var data: [[String: Any]]! = []
    
    var query: QueryDatasetPitStop!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a pull-to-refresh control
        refreshControl = UIRefreshControl ()
        refreshControl?.addTarget(self, action: #selector(QueryViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        
        let enabled_preference = UserDefaults.standard.bool(forKey: "enabled_preference")
        NSLog("enabled_preference: \(enabled_preference)")
        
        query = QueryDatasetPitStop()
        query.execute()
        
        var queryTree = QueryDatasetStreetTree()
        queryTree.execute()
        
        // Auto-refresh
        refresh(self)
    }
    
    /// Asynchronous performs the data query then updates the UI
    
    //JMW: added @objc
    @objc func refresh (_ sender: Any) {

        //let cngQuery = client.query(dataset: "2zah-tuvt")
        let cngQuery = client.query(dataset: "snkr-6jdf")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        // NOTE: removed the orderDescending() action on "id" from original sample
        cngQuery.get { res in
            switch res {
            case .dataset (let data):
                // Update our data
                self.data = data
            case .error (let err):
                let errorMessage = (err as NSError).userInfo.debugDescription
                let alertController = UIAlertController(title: "Error Refreshing", message: errorMessage, preferredStyle:.alert)
                self.present(alertController, animated: true, completion: nil)
            }
 
            // Update the UI
            self.refreshControl?.endRefreshing()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.reloadData()
            self.updateMap(animated: true)
        }

    }
    
    /// Finds the map controller and updates its data
    fileprivate func updateMap(animated: Bool) {
        if let tabs = (self.parent?.parent as? UITabBarController) {
            if let mapNav = tabs.viewControllers![1] as? UINavigationController {
                if let map = mapNav.viewControllers[0] as? MapViewController {
                    map.update(withData: data, animated: animated)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: cellId) as UITableViewCell!
        
        let item = data[indexPath.row]

        for (key,value) in item {
            print( "KEY '\(key)' VALUE '\(value)' ")
        }
        
        let location = item["location"]! as! String
        c?.textLabel?.text = location
        
        let neighborhood = item["neighborhood"]! as! String
        let hoursofoperation = item["hoursofoperation"]! as! String
        c?.detailTextLabel?.text = "\(neighborhood), \(location), \(hoursofoperation)"
        
        return c!
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let detailsVC = segue.destination as! EventDetailsViewController
            detailsVC.eventDictionary = data[self.tableView.indexPathForSelectedRow!.row]
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
