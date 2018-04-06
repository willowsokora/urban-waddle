//
//  DiscoveryViewController.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 3/22/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit
import CoreLocation

class DiscoveryViewController: UIViewController {
    
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    var yelpRestaurants = [YelpRestaurant]()
    
    @IBOutlet weak var swipeableView: ZLSwipeableView!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    
    var cardIndex = 0
    var topCard = 0 {
        didSet {
            undoButton.isEnabled = topCard != 0
            likeButton.isEnabled = topCard < yelpRestaurants.count
            dislikeButton.isEnabled = topCard < yelpRestaurants.count
            if topCard == yelpRestaurants.count - 2 {
                getNextPageFromYelp()
                emptyLabel.isHidden = true
            } else if topCard >= yelpRestaurants.count {
                emptyLabel.isHidden = false
            } else {
                emptyLabel.isHidden = true
            }
        }
    }
    
    @IBAction func openDetail(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended && topCard < yelpRestaurants.count {
            performSegue(withIdentifier: "showDiscoveryDetail", sender: self)
        }
    }
    @IBOutlet weak var emptyLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        currentLocation = nil
        
        swipeableView.numberOfActiveView = UInt(2)
        swipeableView.nextView = {
            return self.nextCardView()
        }
        swipeableView.didSwipe = { view, direction, vector in
            self.handleSwipe(view as! DiscoveryCardView, direction)
            self.topCard += 1
        }
        
    }
    
    @IBAction func goToSettings(_ sender: UIButton) {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    func reloadRestaurants() {
        cardIndex = 0
        emptyLabel.isHidden = true
        yelpRestaurants.removeAll()
        if let currentLocation = currentLocation {
            YelpAPI.getRestaurants(near: currentLocation) { (results) in
                switch results {
                case .success(let searchResults):
                    let savedIds = Restaurant.getAllSavedIds()
                    var newRestaurantsFound = false
                    for restaurant in searchResults.businesses {
                        if !savedIds.contains(restaurant.id) {
                            self.yelpRestaurants.append(restaurant)
                            newRestaurantsFound = true
                        }
                    }
                    if !newRestaurantsFound {
                        self.topCard = self.yelpRestaurants.count
                        return
                    }
                    DispatchQueue.global().async {
                        DispatchQueue.main.sync {
                            print("Retrieved data from yelp, reloading table")
                            self.swipeableView.loadViews()
                            self.topCard = 0
                        }
                    }
                case .failure(let error):
                    fatalError("error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getNextPageFromYelp() {
        if let currentLocation = currentLocation {
            YelpAPI.getRestaurants(near: currentLocation) { (results) in
                switch results {
                case .success(let searchResults):
                    let savedIds = Restaurant.getAllSavedIds()
                    for restaurant in searchResults.businesses {
                        if !savedIds.contains(restaurant.id) {
                            self.yelpRestaurants.append(restaurant)
                        }
                    }
                    DispatchQueue.global().async {
                        DispatchQueue.main.sync {
                            print("Retrieved data from yelp, reloading table")
                            self.swipeableView.loadViews()
                        }
                    }
                case .failure(let error):
                    fatalError("error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func nextCardView() -> UIView? {
        if cardIndex >= yelpRestaurants.count {
            return nil
        }
        let contentView = Bundle.main.loadNibNamed("DiscoveryCardView", owner: self, options: nil)?.first! as! DiscoveryCardView
        contentView.frame = swipeableView.bounds
        contentView.layoutIfNeeded()
        contentView.restaurant = yelpRestaurants[cardIndex]
        contentView.awakeFromNib()
        contentView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        contentView.layer.cornerRadius = 12
        cardIndex += 1
        return contentView
    }
    
    func handleSwipe(_ view: DiscoveryCardView, _ direction: Direction) {
        let restaurant = view.restaurant!
        Restaurant.add(restaurant: restaurant, status: direction == .Right ? .interested : .uninterested)
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if let destination = segue.destination as? DiscoveryDetailViewController {
            destination.restaurant = yelpRestaurants[topCard]
            destination.cardView = swipeableView
        }
     }
 
 
    @IBAction func swipeRight(_ sender: UIButton) {
        swipeableView.swipeTopView(inDirection: .Right)
    }
    
    @IBAction func swipeLeft(_ sender: UIButton) {
        swipeableView.swipeTopView(inDirection: .Left)
    }
    
    @IBAction func undoSwipe(_ sender: UIButton) {
        swipeableView.rewind()
        topCard -= 1
        Restaurant.remove(restaurant: yelpRestaurants[topCard])
    }
    
}

extension DiscoveryViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentLocation == nil {
            currentLocation = locations.first
            reloadRestaurants()
        }
    }
}
