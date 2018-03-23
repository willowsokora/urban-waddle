//
//  DiscoveryViewController.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 3/22/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class DiscoveryViewController: UIViewController {

    @IBOutlet weak var discoveryTable: UITableView!
    var yelpRestaurants = [YelpRestaurant]()
    
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        discoveryTable.dataSource = self
        discoveryTable.delegate = self
        
        let nib = UINib.init(nibName: "DiscoverCell", bundle: nil)
        discoveryTable.register(nib, forCellReuseIdentifier: "discoverCell")
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        currentLocation = nil
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

extension DiscoveryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yelpRestaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "discoverCell", for: indexPath) as! DiscoverCell
        let restaurant = yelpRestaurants[indexPath.row]
        cell.nameLabel.text = restaurant.name
        cell.noteLabel.text = restaurant.location.address1
        cell.ratingLabel.text = "\(restaurant.rating)"
        cell.priceLabel.text = restaurant.price
        return cell
    }
}

extension DiscoveryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DiscoveryViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentLocation == nil {
            currentLocation = locations.first
            getRestaurants(near: (currentLocation?.coordinate)!) { (results) in
                switch results {
                case .success(let searchResults):
                    self.yelpRestaurants = searchResults.businesses
                    DispatchQueue.global().async {
                        DispatchQueue.main.sync {
                            print("Retrieved data from yelp, reloading table")
                            self.discoveryTable.reloadData()
                        }
                    }
                case .failure(let error):
                    fatalError("error: \(error.localizedDescription)")
                }
            }
        }
    }
}
