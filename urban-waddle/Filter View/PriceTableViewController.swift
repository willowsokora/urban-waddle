//
//  PriceTableViewController.swift
//  urban-waddle
//
//  Created by Jonah Zukosky on 4/19/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit

class PriceTableViewController: UITableViewController {

    let savedSelectedPrices = UserDefaults.standard
    let prices: [String] = ["$","$$","$$$","$$$$"]
    var selectedPrices: [String] = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedPrices = savedSelectedPrices.stringArray(forKey: "SavedPriceArray") ?? [String]()
    }
    override func viewDidDisappear(_ animated: Bool) {
        savedSelectedPrices.set(selectedPrices,forKey: "SavedPriceArray")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prices.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "priceCell", for: indexPath)
        cell.textLabel?.text = prices[indexPath.row]
        cell.accessoryType = selectedPrices.contains(prices[indexPath.row]) ? .checkmark : .none
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.selectedPrices.contains(prices[indexPath.row]) {
            selectedPrices = selectedPrices.filter{$0 != prices[indexPath.row]}
        }else {
            selectedPrices.append(prices[indexPath.row])
        }
        tableView.reloadData()
        
    }


}
