//
//  RestaurantCalloutView.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 3/30/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit
import MapKit

class RestaurantCalloutView: UIView {

    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressButton: UIButton!
    
    var restaurant: Restaurant?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
        layer.borderWidth = 2
        if let restaurant = restaurant {
            layer.borderColor = restaurant.statusColor.cgColor
            ratingLabel.text = "\(restaurant.yelpRating)/5"
            priceLabel.text = restaurant.yelpPrice
            addressButton.setTitle(restaurant.address, for: .normal)
        }
    }
    
    @IBAction func getDirections(_ sender: UIButton) {
        guard let restaurant = restaurant else {
            return
        }
        let coordinate = CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)
        let item = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    //    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        let hitView = super.hitTest(point, with: event)
//        if hitView != nil {
//            superview?.bringSubview(toFront: self)
//        }
//        return hitView
//    }
//
//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        let rect = bounds
//        var isInside = rect.contains(point)
//        if(!isInside)
//        {
//            for view in subviews
//            {
//                isInside = view.frame.contains(point)
//                if isInside
//                {
//                    break
//                }
//            }
//        }
//        return isInside
//    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
