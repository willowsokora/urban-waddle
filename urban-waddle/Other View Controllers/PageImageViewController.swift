//
//  PageImageViewController.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 4/5/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit

class PageImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?
    var index: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let image = image {
            let gradient = CAGradientLayer()
            gradient.frame = imageView.bounds
            gradient.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0.3).cgColor]
            imageView.layer.addSublayer(gradient)
            imageView.image = image
        }
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
