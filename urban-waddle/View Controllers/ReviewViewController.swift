//
//  ReviewViewController.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 3/29/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit
import MapKit
import SafariServices
import CoreLocation
import Contacts

class ReviewViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var noteField: UITextView!
    @IBOutlet weak var statusSelector: UISegmentedControl!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var siteButton: UIButton!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    var restaurant: Restaurant?
    var images: [UIImage] = []
    
    //Note Field scrolling
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //MARK: Note Field Setup
        
        //Sizing
        noteField.sizeThatFits(CGSize(width: noteField.frame.size.width, height: noteField.frame.size.height))
        
        //Keyboard Done Button
        let viewForDoneButtonOnKeyboard = UIToolbar()
        viewForDoneButtonOnKeyboard.sizeToFit()
        let spaceBar = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let btnDoneOnKeyboard = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneBtnFromKeyboardClicked))
        viewForDoneButtonOnKeyboard.items = [spaceBar, btnDoneOnKeyboard]
        noteField.inputAccessoryView = viewForDoneButtonOnKeyboard
        noteField.delegate = self
        
        // Keyboard observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Add Tap Gesture for contentView
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        
        
        // MARK: Label Setting
        if let restaurant = restaurant {
            nameLabel.text = restaurant.name
            ratingLabel.text = "\(restaurant.yelpRating)/5"
            priceLabel.text = restaurant.yelpPrice
            if let note = restaurant.note {
                noteField.text = note
            } else {
                noteField.text = "Add a note"
                noteField.textColor = UIColor.lightGray
            }
            phoneButton.setTitle(restaurant.phoneNumber, for: .normal)
            addressButton.setTitle(restaurant.address, for: .normal)
//            let coordinates = CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)
//            mapView.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpanMake(0.1, 0.1)), animated: true)
//            mapView.showsUserLocation = true
//            mapView.addAnnotation(RestaurantAnnotation(restaurant: restaurant))
            statusSelector.selectedSegmentIndex = Int(restaurant.rawStatus)
            
            siteButton.setTitle("Yelp Site", for: .normal)
            siteButton.setTitle("There is no website", for: .disabled)
            if URL.init(string: restaurant.url) != nil {
                siteButton.isEnabled = true
            } else {
                siteButton.isEnabled = false
            }
            
            //Page View Setup
            let pageView = self.childViewControllers[0] as! UIPageViewController
            YelpAPI.getDetails(for: restaurant.yelpId) { (results) in
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
            pageView.dataSource = self
            let appearance = UIPageControl.appearance()
            appearance.currentPageIndicatorTintColor = .purple
            appearance.pageIndicatorTintColor = .lightGray
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//MARK:  Handle Restaurant Buttons
    @IBAction func call(_ sender: UIButton) {
        if let phoneUrl = URL(string: "tel:\(phoneButton.title(for: .normal) ?? "")") {
            if UIApplication.shared.canOpenURL(phoneUrl) {
                UIApplication.shared.open(phoneUrl)
            }
        }
    }
    
    @IBAction func getDirections(_ sender: UIButton) {
        guard let restaurant = restaurant else {return}
        let coordinates = CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
        mapItem.name = restaurant.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    @IBAction func openSite(_ sender: UIButton) {
        guard let urlString = restaurant?.url else {return}
        
        if let url = URL(string: urlString) {
            
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
            
        }
    }

}


//MARK: Image Page Controller
extension ReviewViewController: UIPageViewControllerDataSource {
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


// MARK: Note Field Scroll Handling
extension ReviewViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardHeight != nil {
            return
        }
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            
            // so increase contentView's height by keyboard height
            UIView.animate(withDuration: 0.3, animations: {
                self.constraintContentHeight.constant += self.keyboardHeight
            })
            
            // move if keyboard hide input field
            let distanceToBottom = self.scrollView.frame.size.height - noteField.frame.origin.y - noteField.frame.size.height
            let collapseSpace = keyboardHeight - distanceToBottom
            
            if collapseSpace < 0 {
                // no collapse
                return
            }
            
            // set new offset for scroll view
            UIView.animate(withDuration: 0.3, animations: {
                // scroll to the position above keyboard 10 points
                self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace + 10)
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.scrollView.contentOffset = self.lastOffset
        keyboardHeight = nil
    }
    @objc func doneBtnFromKeyboardClicked() {
        //Hide Keyboard by endEditing or Anything you want.
        self.view.endEditing(true)
    }
    
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        noteField.resignFirstResponder()
    }
}

extension ReviewViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add a note"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        lastOffset = self.scrollView.contentOffset
        return true
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
}

//MARK: Navigation Bar Button Handling
extension ReviewViewController {
    
    @IBAction func cancelReview(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func saveReview(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        guard let restaurant = restaurant else {
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        restaurant.status = Restaurant.Status(rawValue: Int16(statusSelector.selectedSegmentIndex))!
        if !noteField.text.isEmpty && noteField.textColor != .lightGray {
            restaurant.note = noteField.text
        }
        do {
            try context.save()
        } catch {
            print("Failed to save review: \(error.localizedDescription)")
        }
    }
}
