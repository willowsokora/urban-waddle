//
//  FilteringTableViewController.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 4/22/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit
import CoreData

class FilteringTableViewController: UIViewController {
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    let store = UserDefaults.standard
    
    let sectionTitles = ["Prices", "Cities", "Tags"]
    var sectionContent: [[String]] = [[], [], []]
    var selectedContent: [[String]] = [[], [], []]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        request.returnsObjectsAsFaults = false
        request.returnsDistinctResults = true
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let results = try context.fetch(request)
            for tag in results as! [Tag] {
                sectionContent[2].append(tag.title!)
            }
        } catch {
            print("Failed to load tags: \(error.localizedDescription)")
        }
        
        let restaurants = Restaurant.getAllInterestedRestaurants()
        for restaurant in restaurants {
            if !sectionContent[0].contains(restaurant.yelpPrice) {
                sectionContent[0].append(restaurant.yelpPrice)
            }
            if !sectionContent[1].contains(restaurant.city) {
                sectionContent[1].append(restaurant.city)
            }
        }
        
        sectionContent[0].sort()
        sectionContent[1].sort()
        sectionContent[2].sort()

        selectedContent[0] = store.stringArray(forKey: "SavedPricesArray") ?? []
        selectedContent[1] = store.stringArray(forKey: "SavedCitiesArray") ?? []
        selectedContent[2] = store.stringArray(forKey: "SavedTagArray") ?? []
        
        for section in 0...2 {
            var indexes = [IndexPath]()
            for i in 0..<sectionContent[section].count {
                indexes.append(IndexPath(row: i, section: section))
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: indexes, with: .automatic)
            tableView.endUpdates()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        store.set(selectedContent[0], forKey: "SavedPricesArray")
        store.set(selectedContent[1], forKey: "SavedCitiesArray")
        store.set(selectedContent[2], forKey: "SavedTagArray")
        dismiss(animated: true)
    }
    
    @IBAction func clearSelections(_ sender: UIButton) {
        for i in 0..<selectedContent.count {
            selectedContent[i].removeAll()
            tableView.reloadData()
        }
    }
}

extension FilteringTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.backgroundView = nil
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionContent[section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterRow", for: indexPath)
        let title = sectionContent[indexPath.section][indexPath.row]
        cell.textLabel?.text = title
        cell.accessoryType = selectedContent[indexPath.section].contains(title) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
}

extension FilteringTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectedContent[indexPath.section].contains(sectionContent[indexPath.section][indexPath.row]) {
            selectedContent[indexPath.section] = selectedContent[indexPath.section].filter{$0 != sectionContent[indexPath.section][indexPath.row]}
        } else {
            selectedContent[indexPath.section].append(sectionContent[indexPath.section][indexPath.row])
        }
        tableView.reloadData()
    }
}

extension FilteringTableViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
