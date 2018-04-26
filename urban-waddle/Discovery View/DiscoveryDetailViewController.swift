//
//  DiscoveryDetailViewController.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 4/5/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

class DiscoveryDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var yelpButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var ratingImage: UIImageView!
    
    var restaurant: YelpRestaurant?
    var cardView: ZLSwipeableView?
    var images: [UIImage] = []
    var unformattedPhoneNumber: String?
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        likeButton.imageView?.tintColor = statusColors[0]
        dislikeButton.imageView?.tintColor = .red
        addressButton.contentHorizontalAlignment = .left
        addressButton.titleLabel?.textAlignment = .left
        
        let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(dismissView))
        gestureRecognizer.direction = .down
        view.addGestureRecognizer(gestureRecognizer)
        
        // Do any additional setup after loading the view.
        if let restaurant = restaurant {
            nameLabel.text = restaurant.name
            ratingImage.image = UIImage(named: "\(restaurant.rating)stars")
            priceLabel.text = restaurant.price
            addressButton.setTitle(restaurant.location.address1, for: .normal)
            callButton.setTitle(Restaurant.format(phoneNumber: restaurant.phone), for: .normal)
            unformattedPhoneNumber = restaurant.phone
            var tagText = ""
            for category in restaurant.categories {
                tagText.append("\(category.title), ")
            }
            tagsLabel.text = String(tagText.prefix(tagText.count - 2))
            yelpButton.setTitle("Yelp Site", for: .normal)
            yelpButton.setTitle("There is no website", for: .disabled)
            if URL.init(string: restaurant.url) != nil {
                yelpButton.isEnabled = true
            } else {
                yelpButton.isEnabled = false
            }
            let pageView = self.childViewControllers[0] as! UIPageViewController
            if let url = URL(string: restaurant.imageUrl), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                images.append(image)
            }
            if self.images.count > 0 {
                let firstController = self.getPageController(for: 0)!
                let startingViewControllers = [firstController]
                pageView.setViewControllers(startingViewControllers, direction: .forward, animated: false, completion: nil)
            }
            if Reachability.isConnectedToNetwork() {
                YelpAPI.getDetails(for: restaurant.id) { (results) in
                    switch results {
                    case .success(let details):
                        for imageUrl in details.photos.dropFirst() {
                            if let url = URL(string: imageUrl), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                                self.images.append(image)
                            }
                        }
                        if self.images.count > 0 {
                            let firstController = self.getPageController(for: 0)!
                            let startingViewControllers = [firstController]
                            pageView.setViewControllers(startingViewControllers, direction: .forward, animated: false, completion: nil)
                        }
                    case .failure(let error):
                        fatalError("error: \(error.localizedDescription)")
                    }
                }
            }
            pageView.dataSource = self
            
            let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
            effectView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(effectView)
            effectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            effectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            effectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            effectView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func getDirections(_ sender: UIButton) {
        guard let restaurant = restaurant else {return}
        let coordinates = CLLocationCoordinate2D(latitude: restaurant.coordinates.latitude, longitude: restaurant.coordinates.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
        mapItem.name = restaurant.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    @IBAction func openYelp(_ sender: UIButton) {
        guard let urlString = restaurant?.url else {return}
        
        if let url = URL(string: urlString) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        }
    }
    
    @IBAction func call(_ sender: UIButton) {
        if let phoneUrl = URL(string: "tel:\(unformattedPhoneNumber ?? "")") {
            if UIApplication.shared.canOpenURL(phoneUrl) {
                UIApplication.shared.open(phoneUrl)
            }
        }
    }
    
    @IBAction func like(_ sender: UIButton) {
        if let cardView = cardView {
            dismiss(animated: true)
            cardView.swipeTopView(inDirection: .Right)
        }
    }
    
    @IBAction func dislike(_ sender: UIButton) {
        if let cardView = cardView {
            dismiss(animated: true)
            cardView.swipeTopView(inDirection: .Left)
        }
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

extension DiscoveryDetailViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let page = viewController as? PageImageViewController {
            if page.index > 0 {
                return getPageController(for: page.index - 1)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let page = viewController as? PageImageViewController {
            if page.index + 1 < images.count {
                return getPageController(for: page.index + 1)
            }
        }
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return images.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    private func getPageController(for index: Int) -> PageImageViewController? {
        if index < images.count {
            let pageView = storyboard?.instantiateViewController(withIdentifier: "PageImageViewController") as! PageImageViewController
            pageView.index = index
            pageView.image = images[index]
            return pageView
        }
        return nil
    }
}
