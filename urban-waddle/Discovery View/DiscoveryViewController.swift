//
//  DiscoveryViewController.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 3/22/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit
import CoreLocation
import StoreKit

class DiscoveryViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    var yelpRestaurants = [YelpRestaurant]()
    
    @IBOutlet weak var swipeableView: ZLSwipeableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tutorialView: UIView!
    
    var cardIndex = 0
    var topCard = 0 {
        didSet {
            if topCard == yelpRestaurants.count - 2 {
                getNextPageFromYelp()
                emptyLabel.isHidden = true
                swipeableView.isHidden = false
            } else if topCard >= yelpRestaurants.count {
                emptyLabel.isHidden = false
                swipeableView.isHidden = true
            } else {
                emptyLabel.isHidden = true
                swipeableView.isHidden = false
            }
        }
    }
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tutorialView.isHidden = UserDefaults.standard.bool(forKey: "TutorialCompleted")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleReloadTap))
        activityIndicator.addGestureRecognizer(tap)
        
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
        swipeableView.swiping = { view, location, translation in
            let card = view as! DiscoveryCardView
            card.interestedLabel.isHidden = translation.x < 1
            card.interestedLabel.layer.borderColor = card.interestedLabel.textColor.withAlphaComponent(translation.x / 100).cgColor
            card.interestedLabel.textColor = card.interestedLabel.textColor.withAlphaComponent(translation.x / 100)
            card.notInterestedLabel.isHidden = translation.x > -1
            card.notInterestedLabel.layer.borderColor = card.notInterestedLabel.textColor.withAlphaComponent(translation.x / -100).cgColor
            card.notInterestedLabel.textColor = card.notInterestedLabel.textColor.withAlphaComponent(translation.x / -100)
        }
        swipeableView.didCancel = { view in
            let card = view as! DiscoveryCardView
            card.interestedLabel.isHidden = true
            card.notInterestedLabel.isHidden = true
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        reloadRestaurants()
    }

    func reloadRestaurants() {
        if Reachability.isConnectedToNetwork() {
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
                                self.activityIndicator.stopAnimating()
                                self.swipeableView.loadViews()
                                self.topCard = 0
                            }
                        }
                    case .failure(let error):
                        self.activityIndicator.startAnimating()
                        fatalError("error: \(error.localizedDescription)")
                    }
                }
            }
        }else {
            self.activityIndicator.startAnimating()
        }
    }
    
    func getNextPageFromYelp() {
        if Reachability.isConnectedToNetwork() {
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
                                self.activityIndicator.stopAnimating()
                                self.swipeableView.loadViews()
                            }
                        }
                    case .failure(let error):
                        self.activityIndicator.startAnimating()
                        fatalError("error: \(error.localizedDescription)")
                    }
                }
            }
        }else {
            self.activityIndicator.startAnimating()
        }
    }
    
    func shouldInclude(yelp restaurant: YelpRestaurant) -> Bool {
        let store = UserDefaults.standard
        let tagFilters = store.stringArray(forKey: "SavedTagArray") ?? []
        let priceFilters = store.stringArray(forKey: "SavedPricesArray") ?? []
        let cityFilters = store.stringArray(forKey: "SavedCitiesArray") ?? []
        
        let deselectedTags = store.stringArray(forKey: "DeselectedTagArray") ?? []
        let deselectedPrices = store.stringArray(forKey: "DeselectedPricesArray") ?? []
        let deselectedCities = store.stringArray(forKey: "DeseletedCitiesArray") ?? []
        
        var filtered = false
        for tag in restaurant.categories {
            if deselectedTags.contains(tag.title) {
                filtered = true
            }
        }
        filtered = filtered || deselectedPrices.contains(restaurant.price ?? "$") || deselectedCities.contains(restaurant.location.city)
        
        var include = false
        if tagFilters.count > 0 {
            for tag in restaurant.categories {
                if tagFilters.contains(tag.title) {
                    include = true
                }
            }
        } else {
            include = true
        }
        
        if cityFilters.count > 0 {
            include = include && cityFilters.contains(restaurant.location.city)
        }
        
        if priceFilters.count > 0 {
            include = include && priceFilters.contains(restaurant.price ?? "$")
        }
        return include && !filtered
    }
    
    func nextCardView() -> UIView? {
        if cardIndex >= yelpRestaurants.count {
            activityIndicator.startAnimating()
            return nil
        }
        activityIndicator.stopAnimating()
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
        DispatchQueue.main.async {
            let restaurant = view.restaurant!
            Restaurant.add(restaurant: restaurant, status: direction == .Right ? .interested : .uninterested)
            
            if direction == .Right {
                if 52 == Int(arc4random_uniform(500)) {
                    if #available( iOS 10.3,*){
                        SKStoreReviewController.requestReview()
                    }
                }
            }
        }
    }
    
    @objc func handleReloadTap() {
        reloadRestaurants()
        //TODO: reload the cards. Jacob do this IDK how also please in viewWillAppear maybe
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
     }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake && topCard != 0 {
            swipeableView.rewind()
            topCard -= 1
            Restaurant.remove(restaurant: yelpRestaurants[topCard])
            let top = swipeableView.activeViews().first as! DiscoveryCardView
            top.interestedLabel.isHidden = true
            top.notInterestedLabel.isHidden = true
        }
    }
    
    @IBAction func dismissTutorial(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "TutorialCompleted")
        tutorialView.isHidden = true
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

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

