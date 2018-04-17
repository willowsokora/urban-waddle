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
    func dropPinZoomIn(for restaurant: String, placemark:MKPlacemark)
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let defaultButtonColor = UIButton(type: UIButtonType.system).titleColor(for: .normal)!
    var resultSearchController:UISearchController? = nil
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var selectedRestaurant: Restaurant?
    let locationButton = UIButton(type: UIButtonType.custom) as UIButton
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Map Setup
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
        searchBar.placeholder = "Waddl your way to new food"
        
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        // Navigation Bar Clearing
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        //Center Location on User Button
        
        let locationImage = UIImage(named: "location") as UIImage?
        let tintedImage = locationImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        locationButton.frame = CGRect(origin: CGPoint(x: 320, y: 670), size: CGSize(width: 35, height: 38))
        locationButton.setImage(tintedImage, for: .normal)
        locationButton.tintColor = defaultButtonColor
        locationButton.layer.cornerRadius = 10
        locationButton.backgroundColor = .white
        locationButton.addTarget(self, action: #selector(MapViewController.centerMapOnUserButtonClicked), for:.touchUpInside)
        mapView.addSubview(locationButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.removeAnnotations(mapView.annotations)
        for restaurant in Restaurant.getAllInterestedRestaurants() {
            mapView.addAnnotation(RestaurantAnnotation(restaurant: restaurant))
        }
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ReviewViewController {
            destination.restaurant = selectedRestaurant
        }
    }
    
    @objc func getDirections(){
        if let selected = selectedRestaurant {
            let coordinate = CLLocationCoordinate2D(latitude: selected.latitude, longitude: selected.longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
            mapItem.name = selected.name
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    @objc func reviewRestaurant() {
        if selectedRestaurant != nil {
            performSegue(withIdentifier: "reviewFromMapSegue", sender: self)
        }
    }
    
    @objc func centerMapOnUserButtonClicked() {
        switch mapView.userTrackingMode {
        case .follow :
            mapView.setUserTrackingMode(MKUserTrackingMode.none, animated: true)
        case .none :
            mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        default :
            mapView.setUserTrackingMode(MKUserTrackingMode.none, animated: true)
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

extension MapViewController: HandleMapSearch {
    // Handle Pin for Restaurants from Search
    func dropPinZoomIn(for restaurant: String, placemark:MKPlacemark){
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        var annotationFound = false
        for annotation in mapView.annotations {
            if let restaurantAnnotation = annotation as? RestaurantAnnotation {
                if restaurantAnnotation.restaurant.yelpId == restaurant {
                    mapView.selectAnnotation(restaurantAnnotation, animated: true)
                    annotationFound = true
                }
            }
        }
        if !annotationFound {
            YelpAPI.getDetails(for: restaurant) { (results) in
                switch results {
                case .success(let details):
                    let data = Restaurant.add(restaurant: details, status: .interested)
                    let annotation = RestaurantAnnotation(restaurant: data)
                    self.mapView.addAnnotation(annotation)
                    self.mapView.selectAnnotation(annotation, animated: true)
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
                }
            }
        }
        resultSearchController?.searchBar.text = ""
    }
}
extension MapViewController : MKMapViewDelegate {
    
    //Handle Selection of Pin
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? RestaurantAnnotation {
            selectedRestaurant = annotation.restaurant
            mapView.setCenter(CLLocationCoordinate2D(latitude: (selectedRestaurant?.latitude)!, longitude: (selectedRestaurant?.longitude)!), animated: true)

            let span = MKCoordinateSpanMake(0.01, 0.01)
            //Only zoom in, not zoom out
            if span.latitudeDelta < mapView.region.span.latitudeDelta {
                let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
                mapView.setRegion(region, animated: true)
            }
            
        }
    }
    
    //Handle Deselection of Pin
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        selectedRestaurant = nil
    }
    
    //Creation of Restaurant Callout View
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
            let discloseButton = UIButton.init(type: .detailDisclosure)
            discloseButton.addTarget(self, action: #selector(self.reviewRestaurant), for: .touchUpInside)
            markerView.leftCalloutAccessoryView = discloseButton
            let label = UILabel()
            label.text = "\(restaurant.yelpPrice)   \(restaurant.yelpRating)/5"
            markerView.detailCalloutAccessoryView = label
            let directionsButton = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
            directionsButton.setBackgroundImage(UIImage(named: "car")?.withRenderingMode(.alwaysTemplate), for: .normal)
            directionsButton.tintColor = .blue
            directionsButton.addTarget(self, action: #selector(self.getDirections), for: .touchUpInside)
            markerView.rightCalloutAccessoryView = directionsButton
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
