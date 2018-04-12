//
//  SavedViewController.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 3/22/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit

class SavedViewController: UIViewController {

    @IBOutlet weak var savedTable: UITableView!
    
    var savedRestaurants = [[Restaurant]]()
    var filteredRestaurants = [[Restaurant]]()
    
    let sectionNames = ["Liked", "Interested", "Disliked"]
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        savedTable.dataSource = self
        savedTable.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Saved Restaurants"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        savedRestaurants = Restaurant.getAllInterestedRestaurantsSeparated()
        savedTable.reloadData()
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
            destination.restaurant = savedRestaurants[(savedTable.indexPathForSelectedRow?.section)!][(savedTable.indexPathForSelectedRow?.row)!]
        }
    }

    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredRestaurants = [[], [], []]
        for i in 0..<savedRestaurants.count{
            filteredRestaurants[i] = savedRestaurants[i].filter({(restaurant: Restaurant) -> Bool in
                if restaurant.name.lowercased().contains(searchText.lowercased()) {
                    return true
                } else {
                    for tag in restaurant.tags.components(separatedBy: ",") {
                        if tag.lowercased().contains(searchText.lowercased()) {
                            return true
                        }
                    }
                }
                return false
            })
        }
        savedTable.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

extension SavedViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionNames.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredRestaurants[section].count
        }
        return savedRestaurants[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath)
        let restaurant: Restaurant
        if isFiltering() {
            restaurant = filteredRestaurants[indexPath.section][indexPath.row]
        } else {
            restaurant = savedRestaurants[indexPath.section][indexPath.row]
        }
        cell.textLabel?.text = restaurant.name
        return cell
    }
}

extension SavedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        headerView.textLabel?.text = sectionNames[section]
        headerView.textLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        headerView.textLabel?.textColor = statusColors[section]
        return headerView
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "") { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            let restaurant = self.savedRestaurants[indexPath.section][indexPath.row]
            Restaurant.remove(restaurant: restaurant)
            success(true)
        }
        deleteAction.image = UIImage(named: "delete")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension SavedViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
