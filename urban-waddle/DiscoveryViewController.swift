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

import UIKit
import CoreLocation
import CoreData

class DiscoveryViewController: UIViewController {
    
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    var yelpRestaurants = [YelpRestaurant]()
    
    @IBOutlet weak var swipeableView: ZLSwipeableView!
    
    var cardIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.clipsToBounds = true
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        currentLocation = nil
        
        swipeableView.nextView = {
            return self.nextCardView()
        }
    }
    
    @IBAction func reloadDeck(_ sender: UIButton) {
        YelpAPI.page = 0
        reloadRestaurants()
    }
    
    func reloadRestaurants() {
        yelpRestaurants.removeAll()
        if let currentLocation = currentLocation {
            YelpAPI.getRestaurants(near: currentLocation) { (results) in
                switch results {
                case .success(let searchResults):
                    self.yelpRestaurants = searchResults.businesses
                    DispatchQueue.global().async {
                        DispatchQueue.main.sync {
                            print("Retrieved data from yelp, reloading table")
                            self.swipeableView.discardViews()
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
        let cardView = UIView(frame: swipeableView.bounds)
        let contentView = Bundle.main.loadNibNamed("DiscoveryCardView", owner: self, options: nil)?.first! as! DiscoveryCardView
        contentView.restaurant = yelpRestaurants[cardIndex]
        contentView.awakeFromNib()
        contentView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        contentView.layer.cornerRadius = 12
        cardView.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = contentView.leftAnchor.constraint(equalTo: cardView.leftAnchor)
        let topConstraint = contentView.topAnchor.constraint(equalTo: cardView.topAnchor)
        let widthConstraint = contentView.widthAnchor.constraint(equalToConstant: cardView.bounds.width)
        let heightConstraint = contentView.heightAnchor.constraint(equalToConstant: cardView.bounds.height)
        //contentView.center = CGPoint(x: cardView.bounds.midX, y: cardView.bounds.midY)
        //contentView.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin]
        //        let leftConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: cardView.bounds.minX)
        //        let topConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: cardView.bounds.minY)
        //        let widthConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: cardView.bounds.width)
        //        let heightConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: cardView.bounds.height)
        cardView.addConstraints([leftConstraint, topConstraint, widthConstraint, heightConstraint])
        cardIndex += 1
        return cardView
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func swipeRight(_ sender: UIButton) {
        swipeableView.swipeTopView(inDirection: .Right)
    }
    
    @IBAction func swipeLeft(_ sender: UIButton) {
        swipeableView.swipeTopView(inDirection: .Left)
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
