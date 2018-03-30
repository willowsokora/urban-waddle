//
//  ReviewViewController.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 3/29/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ReviewViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var noteField: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var statusSelector: UISegmentedControl!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var phoneButton: UIButton!
    
    var restaurant: Restaurant?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navBar.delegate = self
        if let restaurant = restaurant {
            nameLabel.text = restaurant.name
            ratingLabel.text = "\(restaurant.yelpRating)/5"
            priceLabel.text = restaurant.yelpPrice
            if let note = restaurant.note {
                noteField.text = note
            } else {
                noteField.text = "Add a note"
                noteField.delegate = self
                noteField.textColor = UIColor.lightGray
            }
            phoneButton.setTitle(restaurant.phoneNumber, for: .normal)
            let coordinates = CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)
            mapView.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpanMake(0.5, 0.5)), animated: true)
            mapView.showsUserLocation = true
            mapView.addAnnotation(RestaurantAnnotation(restaurant: restaurant))
            switch restaurant.status {
            case .liked:
                statusSelector.selectedSegmentIndex = 0
            case.disliked:
                statusSelector.selectedSegmentIndex = 1
            default:
                statusSelector.selectedSegmentIndex = UISegmentedControlNoSegment
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelReview(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func saveReview(_ sender: UIButton) {
        dismiss(animated: true)
        guard let restaurant = restaurant else {
            return
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        switch statusSelector.selectedSegmentIndex {
        case 0:
            restaurant.status = .liked
        case 1:
            restaurant.status = .disliked
        default:
            break
        }
        if !noteField.text.isEmpty && noteField.textColor != .lightGray {
            restaurant.note = noteField.text
        }
        do {
            try context.save()
        } catch {
            print("Failed to save review: \(error.localizedDescription)")
        }
    }
    
    @IBAction func call(_ sender: UIButton) {
        if let phoneUrl = URL(string: "tel:\(phoneButton.title(for: .normal) ?? "")") {
            if UIApplication.shared.canOpenURL(phoneUrl) {
                UIApplication.shared.open(phoneUrl)
            }
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

extension ReviewViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray
        }
    }
}

extension ReviewViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
