//
//  LocationSearchTable.swift
//  urban-waddle
//
//  Created by Jonah Zukosky on 3/15/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTable : UITableViewController {
    
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate:HandleMapSearch? = nil
    var yelpResults: [YelpRestaurant] = []
    var savedResults: [Restaurant] = []
}

extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text,
            let location = mapView.userLocation.location else { return }
        savedResults = Restaurant.search(term: searchBarText)
        YelpAPI.search(near: location, term: searchBarText) { (results) in
            switch results {
            case .success(let result):
                self.yelpResults = result.businesses
                self.tableView.reloadData()
            case .failure(let error):
                fatalError("error: \(error.localizedDescription)")
            }
        }
    }
    
}

extension LocationSearchTable {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedResults.count + yelpResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell")!
        if indexPath.row < savedResults.count {
            let selectedItem = savedResults[indexPath.row]
            cell.textLabel?.text = selectedItem.name
            cell.detailTextLabel?.text = selectedItem.address
        } else {
            let selectedItem = yelpResults[indexPath.row - savedResults.count]
            cell.textLabel?.text = selectedItem.name
            cell.detailTextLabel?.text = selectedItem.location.address1
        }
        return cell
    }
    
    
}

extension LocationSearchTable {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true)
        if indexPath.row < savedResults.count {
            let selectedItem = savedResults[indexPath.row]
            let coordinate = CLLocationCoordinate2D(latitude: selectedItem.latitude, longitude: selectedItem.longitude)
            handleMapSearchDelegate?.dropPinZoomIn(for: selectedItem.yelpId, placemark: MKPlacemark(coordinate: coordinate))
        } else {
            let selectedItem = yelpResults[indexPath.row - savedResults.count]
            let coordinate = CLLocationCoordinate2D(latitude: selectedItem.coordinates.latitude, longitude: selectedItem.coordinates.longitude)
            handleMapSearchDelegate?.dropPinZoomIn(for: selectedItem.id, placemark: MKPlacemark(coordinate: coordinate))
        }
    }
}
