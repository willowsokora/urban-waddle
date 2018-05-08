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
    
    let sectionTitles = ["Distance", "Prices", "Cities", "Tags"]
    var sectionContent: [[String]] = [[], [], []]
    var selectedContent: [[String]] = [[], [], []]
    var deselectedContent: [[String]] = [[], [], []]
    let searchController = UISearchController(searchResultsController: nil)
    
    var priceBackgroundView = UIView()
    var cityBackgroundView = UIView()
    var tagBackgroundView = UIView()
    var priceLabel = UILabel()
    var cityLabel = UILabel()
    var tagLabel = UILabel()
    
    var maxDistance: Float = 40000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        priceLabel.text = "No Price Filters Yet, Get Waddling!"
        cityLabel.text = "No City Filters Yet, Get Waddling!"
        tagLabel.text = "No Tag Filters Yet, Get Waddling!"
        
        tagBackgroundView.addSubview(tagLabel)
        tableView.backgroundView = tagBackgroundView
        
        navBar.delegate = self

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
        
        let restaurants = Restaurant.getAllInterestedRestaurantsUnfiltered()
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
        
        deselectedContent[0] = store.stringArray(forKey: "DeselectedPricesArray") ?? []
        deselectedContent[1] = store.stringArray(forKey: "DeselectedCitiesArray") ?? []
        deselectedContent[2] = store.stringArray(forKey: "DeselectedTagArray") ?? []
        
//        for section in 0...2 {
//            var indexes = [IndexPath]()
//            for i in 0..<sectionContent[section].count {
//                indexes.append(IndexPath(row: i, section: section))
//            }
//            tableView.beginUpdates()
//            tableView.deleteRows(at: indexes, with: .automatic)
//            tableView.endUpdates()
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        store.set(selectedContent[0], forKey: "SavedPricesArray")
        store.set(selectedContent[1], forKey: "SavedCitiesArray")
        store.set(selectedContent[2], forKey: "SavedTagArray")
        store.set(deselectedContent[0], forKey: "DeselectedPricesArray")
        store.set(deselectedContent[1], forKey: "DeselectedCitiesArray")
        store.set(deselectedContent[2], forKey: "DeselectedTagArray")
        store.set(maxDistance, forKey: "MaxDistance")
        dismiss(animated: true)
    }
    
    @IBAction func clearSelections(_ sender: UIButton) {
        for i in 0..<selectedContent.count {
            selectedContent[i].removeAll()
            deselectedContent[i].removeAll()
            tableView.reloadData()
        }
    }
}

extension FilteringTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        //tableView.backgroundView = nil
        
        if sectionContent[0].count == 0 && sectionContent[1].count == 0 && sectionContent[2].count == 0{
            let noTagLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noTagLabel.text = "You don't have any Filters yet, get Waddling!"
            noTagLabel.textColor = UIColor.lightGray
            noTagLabel.numberOfLines = 0
            noTagLabel.textAlignment = .center
            tableView.backgroundView = noTagLabel
            tableView.separatorStyle = .none
        }
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return sectionContent[section - 1].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sliderRow", for: indexPath) as! SliderTableViewCell
            var distance = UserDefaults.standard.float(forKey: "MaxDistance")
            if distance == 0 {
                distance = 25
            }
            cell.slider.value = distance
            cell.sliderChanged(cell.slider)
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "filterRow", for: indexPath) as! FilterTableViewCell
            let title = sectionContent[indexPath.section - 1][indexPath.row]
            cell.filterLabel.text = title
//            cell.accessoryType = selectedContent[indexPath.section - 1].contains(title) ? .checkmark : .none
            if selectedContent[indexPath.section - 1].contains(title) {
                cell.statusImage.image = UIImage(named: "smallCheck")
                cell.statusImage.tintColor = statusColors[0]
            } else if deselectedContent[indexPath.section - 1].contains(title) {
                cell.statusImage.image = UIImage(named: "smallX")
                cell.statusImage.tintColor = .red
            } else {
                cell.statusImage.image = nil
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
}

extension FilteringTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section  == 0 {
            return
        }
        let title = sectionContent[indexPath.section - 1][indexPath.row]
        if selectedContent[indexPath.section - 1].contains(title) {
            selectedContent[indexPath.section - 1] = selectedContent[indexPath.section - 1].filter{$0 != title}
            deselectedContent[indexPath.section - 1].append(title)
        } else if deselectedContent[indexPath.section - 1].contains(title) {
            deselectedContent[indexPath.section - 1] = deselectedContent[indexPath.section - 1].filter{$0 != title}
        } else {
            selectedContent[indexPath.section - 1].append(sectionContent[indexPath.section - 1][indexPath.row])
        }
        tableView.reloadData()
    }
}

extension FilteringTableViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension FilteringTableViewController: DistanceSliderDelegate {
    func sliderUpdated(distance: Float) {
        maxDistance = distance
    }
}
