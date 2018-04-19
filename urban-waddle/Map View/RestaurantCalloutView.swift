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
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    
    var restaurant: Restaurant?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let restaurant = restaurant {
            priceLabel.text = restaurant.yelpPrice
            ratingImage.image = UIImage(named: "\(restaurant.yelpRating)stars")
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
