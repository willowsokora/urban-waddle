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
    
    let sectionNames = ["Liked", "Interested", "Disliked"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        savedTable.dataSource = self
        savedTable.delegate = self
        
        // Do any additional setup after loading the view.
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

}

extension SavedViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionNames.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedRestaurants[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath)
        let restaurant = savedRestaurants[indexPath.section][indexPath.row]
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
}
