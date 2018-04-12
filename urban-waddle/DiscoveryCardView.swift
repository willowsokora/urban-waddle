//
//  DiscoveryCardView.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 3/26/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit

class DiscoveryCardView: UIView {

    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var interestedLabel: UILabel!
    @IBOutlet weak var notInterestedLabel: UILabel!
    var restaurant: YelpRestaurant?
    
    override func awakeFromNib() {
        let gradient = CAGradientLayer()
        gradient.frame = previewImage.bounds
        gradient.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0.3).cgColor]
        previewImage.layer.addSublayer(gradient)
        if let restaurant = restaurant {
            let imageUrl = URL(string: restaurant.imageUrl)
            if let data = try? Data(contentsOf: imageUrl!) {
                previewImage.image = UIImage(data: data)
            }
            nameLabel.text = restaurant.name
            distanceLabel.text = restaurant.location.address1
            var tagText = ""
            for category in restaurant.categories {
                tagText.append("\(category.title), ")
            }
            tagsLabel.text = String(tagText.prefix(tagText.count - 2))
            priceLabel.text = restaurant.price ?? "$?"
            ratingLabel.text = "\(restaurant.rating)/5"
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
