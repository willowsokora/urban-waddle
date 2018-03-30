//
//  MapViewController.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 3/7/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    var selectedRestaurant: Restaurant?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        currentLocation = nil
        
        mapView.delegate = self
        
        // Search Setup
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search Places"
    
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.removeAnnotations(mapView.annotations)
        for restaurant in Restaurant.getAllInterestedRestaurants() {
            mapView.addAnnotation(RestaurantAnnotation(restaurant: restaurant))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? ReviewViewController {
            destination.restaurant = selectedRestaurant
        }
    }
    
    @objc func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    @objc func reviewRestaurant() {
        if selectedRestaurant != nil {
            performSegue(withIdentifier: "reviewFromMapSegue", sender: self)
        }
    }

}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count != 0 {
            if currentLocation == nil {
                if let location = locations.first {
                    mapView.removeAnnotations(mapView.annotations)
                    for restaurant in Restaurant.getAllInterestedRestaurants() {
                        mapView.addAnnotation(RestaurantAnnotation(restaurant: restaurant))
                    }
                    let span = MKCoordinateSpanMake(0.05, 0.05)
                    let region = MKCoordinateRegion(center: location.coordinate, span: span)
                    mapView.setRegion(region, animated: true)
                }
            }
            currentLocation = locations[locations.count - 1]
        }
    }
}

extension MapViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
    }
}


extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city), \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}
extension MapViewController : MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        if view.annotation is MKUserLocation { return }
//        //hides the pin image
//        selectedPin = MKPlacemark(coordinate: (view.annotation?.coordinate)!)
//        for sub in view.subviews[3].subviews {
//            sub.isHidden = true
//        }
//        if let restaurantAnnotation = view.annotation as? RestaurantAnnotation {
//            if let callout = Bundle.main.loadNibNamed("RestaurantCalloutView", owner: self, options: nil)?.first as? RestaurantCalloutView {
//                let restaurant = restaurantAnnotation.restaurant
//                callout.restaurant = restaurant
//                callout.center = CGPoint(x: view.bounds.size.width / 2, y: -callout.bounds.size.height * 0.5)
//                callout.awakeFromNib()
//                view.addSubview(callout)
//                mapView.setCenter((view.annotation?.coordinate)!, animated: true)
//            }
//        }
//    }
//
//    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
//        for subview in view.subviews {
//            if subview is RestaurantCalloutView {
//                subview.removeFromSuperview()
//            }
//        }
//    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? RestaurantAnnotation {
            selectedRestaurant = annotation.restaurant
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        selectedRestaurant = nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view is MKMarkerAnnotationView {
            reviewRestaurant()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        if let restaurantAnnotation = annotation as? RestaurantAnnotation {
            let reuseId = "marker"
            let markerView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            markerView.titleVisibility = .visible
            markerView.markerTintColor = restaurantAnnotation.restaurant.statusColor
            markerView.canShowCallout = true
            
            let restaurant = restaurantAnnotation.restaurant
            let smallSquare = CGSize(width: 30, height: 30)
            let button = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
            button.imageView?.image = UIImage(named: "disclosure")
            button.setBackgroundImage(UIImage(named: "disclosure"), for: .normal)
            markerView.rightCalloutAccessoryView = button
            let label = UILabel()
            label.text = "\(restaurant.yelpPrice)   \(restaurant.yelpRating)/5"
            markerView.detailCalloutAccessoryView = label
//            let smallSquare = CGSize(width: 30, height: 30)
//            let button = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
//            button.setBackgroundImage(UIImage(named: "fa-car"), for: .normal)
//            button.addTarget(self, action: #selector(self.getDirections), for: .touchUpInside)
//            markerView.leftCalloutAccessoryView = button
            return markerView
        }
        return nil
    }
}

class RestaurantAnnotation: NSObject, MKAnnotation {
    var restaurant: Restaurant
    var coordinate: CLLocationCoordinate2D
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        self.coordinate = CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)
        super.init()
    }
    
    var title: String? {
        return restaurant.name
    }
}
