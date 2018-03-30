//
//  RestaurantCell.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 3/22/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit

class RestaurantCell: UITableViewCell {
    
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var restaurant: Restaurant?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if let restaurant = restaurant {
            nameLabel.text = restaurant.name
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
