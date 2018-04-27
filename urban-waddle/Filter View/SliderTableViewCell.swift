//
//  SliderTableViewCell.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 4/26/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit

class SliderTableViewCell: UITableViewCell {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var detailLabel: UILabel!
    
    var delegate: DistanceSliderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        detailLabel.text = "\(Int(sender.value))\(sender.value > 24 ? "+" : "") mile\(sender.value >= 2 ? "s" : "")"
        if let delegate = delegate {
            delegate.sliderUpdated(distance: slider.value)
        }
    }
}

protocol DistanceSliderDelegate {
    func sliderUpdated(distance: Float)
}
