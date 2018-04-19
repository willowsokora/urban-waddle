//
//  CityTableViewController.swift
//  urban-waddle
//
//  Created by Jonah Zukosky on 4/19/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit

class CityTableViewController: UITableViewController {
    
    let savedSelectedCities = UserDefaults.standard
    let cities: [String] = ["city1","city2","city3","city4","city5","city6"]
    var selectedCities: [String] = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedCities = savedSelectedCities.stringArray(forKey: "SavedCityArray") ?? [String]()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        savedSelectedCities.set(selectedCities,forKey: "SavedCityArray")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        cell.textLabel?.text = cities[indexPath.row]
        cell.accessoryType = selectedCities.contains(cities[indexPath.row]) ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if self.selectedCities.contains(cities[indexPath.row]) {
            selectedCities = selectedCities.filter{$0 != cities[indexPath.row]}
        }else {
            selectedCities.append(cities[indexPath.row])
        }
        tableView.reloadData()
    }


}
