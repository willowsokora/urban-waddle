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
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    
    @IBOutlet weak var leftViewMask: UIView!
    @IBOutlet weak var rightViewMask: UIView!
    
    @IBOutlet weak var interestedLabel: UILabel!
    @IBOutlet weak var notInterestedLabel: UILabel!
    var restaurant: YelpRestaurant?
    var images: [UIImage] = []
    var bars: [UIView] = []
    var currentImage = 0
    
    override func awakeFromNib() {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: bounds.width, height: bounds.height))
        gradient.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0.3).cgColor]
        previewImage.layer.addSublayer(gradient)
        
        leftViewMask.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToPreviousImage)))
        rightViewMask.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToNextImage)))
        
        if let restaurant = restaurant {
            guard let imageUrl = URL(string: restaurant.imageUrl) else {return}
            if let data = try? Data(contentsOf: imageUrl) {
                previewImage.image = UIImage(data: data)
            }
            
            YelpAPI.getDetails(for: restaurant.id) { result in
                switch result {
                case .failure(_):
                    print("Failure to get restaurant details... weird")
                case .success(let details):
                    for imageUrl in details.photos {
                        if let url = URL(string: imageUrl), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                            self.images.append(image)
                        }
                    }
                    if self.images.count > 0 {
                        self.setupImagePages()
                    }
                }
            }
            
            nameLabel.text = restaurant.name
            //distanceLabel.text = restaurant.location.address1
            var tagText = ""
            for category in restaurant.categories {
                tagText.append("\(category.title), ")
            }
            tagsLabel.text = String(tagText.prefix(tagText.count - 2))
            priceLabel.text = restaurant.price ?? "$?"
            ratingImage.image = UIImage(named: "\(restaurant.rating)stars")
            //ratingLabel.text = "\(restaurant.rating)/5"
        }
        interestedLabel.transform = CGAffineTransform(rotationAngle: -0.17)
        interestedLabel.layer.borderWidth = 3
        interestedLabel.layer.cornerRadius = 5
        interestedLabel.layer.borderColor = interestedLabel.textColor.cgColor
        notInterestedLabel.transform = CGAffineTransform(rotationAngle: 0.17)
        notInterestedLabel.layer.borderWidth = 3
        notInterestedLabel.layer.cornerRadius = 5
        notInterestedLabel.layer.borderColor = notInterestedLabel.textColor.cgColor
    }
    
    let margin = CGFloat(3)
    let frameMargin = CGFloat(10)
    
    func setupImagePages() {
        let imageCount = CGFloat(images.count)
        let barWidth = ((frame.width - (frameMargin * 2)) / imageCount) - margin
        let barSize = CGSize(width: barWidth, height: margin)
        var startPoint = CGPoint(x: frame.minX + frameMargin, y: frame.minY + margin)
        for _ in 0..<images.count {
            let bar = UIView(frame: CGRect(origin: startPoint, size: barSize))
            bar.layer.cornerRadius = 2
            bar.backgroundColor = .white
            bar.layer.opacity = 0.5
            addSubview(bar)
            bars.append(bar)
            startPoint = CGPoint(x: startPoint.x + barWidth + margin, y: startPoint.y)
        }
        bars[currentImage].layer.opacity = 1
        previewImage.image = images[currentImage]
    }
    
    @objc func goToNextImage() {
        if currentImage < images.count - 1 {
            bars[currentImage].layer.opacity = 0.5
            currentImage += 1
            previewImage.image = images[currentImage]
            bars[currentImage].layer.opacity = 1
        }
    }
    
    @objc func goToPreviousImage() {
        if currentImage > 0 {
            bars[currentImage].layer.opacity = 0.5
            currentImage -= 1
            previewImage.image = images[currentImage]
            bars[currentImage].layer.opacity = 1
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
