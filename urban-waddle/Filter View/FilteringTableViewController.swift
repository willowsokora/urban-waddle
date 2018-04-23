//
//  FilteringTableViewController.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 4/22/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit
import CoreData

class FilteringTableViewController: UITableViewController {
    
    let store = UserDefaults.standard
    
    let sectionTitles = ["Prices", "Tags", "Cities"]
    var sectionContent: [[String]] = [[], [], []]
    var selectedContent: [[String]] = [[], [], []]
    
    var expandedSection = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        request.returnsObjectsAsFaults = false
        request.returnsDistinctResults = true
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let results = try context.fetch(request)
            for tag in results as! [Tag] {
                sectionContent[1].append(tag.title!)
            }
        } catch {
            print("Failed to load tags: \(error.localizedDescription)")
        }
        
        let restaurants = Restaurant.getAllInterestedRestaurants()
        for restaurant in restaurants {
            if !sectionContent[0].contains(restaurant.yelpPrice) {
                sectionContent[0].append(restaurant.yelpPrice)
            }
            if !sectionContent[2].contains(restaurant.city) {
                sectionContent[2].append(restaurant.city)
            }
        }
        
        sectionContent[0].sort()
        sectionContent[1].sort()
        sectionContent[2].sort()

        selectedContent[0] = store.stringArray(forKey: "SavedPricesArray") ?? []
        selectedContent[1] = store.stringArray(forKey: "SavedTagArray") ?? []
        selectedContent[2] = store.stringArray(forKey: "SavedCitiesArray") ?? []
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.set(selectedContent[0], forKey: "SavedPricesArray")
        store.set(selectedContent[1], forKey: "SavedTagArray")
        store.set(selectedContent[2], forKey: "SavedCitiesArray")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        tableView.backgroundView = nil
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section == expandedSection ? sectionContent[section].count : 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterRow", for: indexPath)
        let title = sectionContent[indexPath.section][indexPath.row]
        cell.textLabel?.text = title
        cell.accessoryType = selectedContent[indexPath.section].contains(title) ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectedContent[indexPath.section].contains(sectionContent[indexPath.section][indexPath.row]) {
            selectedContent[indexPath.section] = selectedContent[indexPath.section].filter{$0 != sectionContent[indexPath.section][indexPath.row]}
        } else {
            selectedContent[indexPath.section].append(sectionContent[indexPath.section][indexPath.row])
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
//        let headerFrame = header.frame.size
//
//        if let oldImage = view.viewWithTag(section + 6900) {
//            oldImage.removeFromSuperview()
//        }
//        let imageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: headerFrame.height / 2 - 9, width: 18, height: 18))
//        imageView.image = UIImage(named: "disclosure")
//        imageView.tag = section + 6900
//        header.addSubview(imageView)
        
        header.tag = section
        let headerTapGesture = UITapGestureRecognizer(target: self, action: #selector(sectionHeaderWasTouched(_:)))
        header.addGestureRecognizer(headerTapGesture)
    }
    
    @IBAction func clearSelections(_ sender: UIButton) {
        for i in 0..<selectedContent.count {
            selectedContent[i].removeAll()
            tableView.reloadData()
        }
    }

    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
        let headerView = sender.view as! UITableViewHeaderFooterView
        let section = headerView.tag
        let detail = headerView.viewWithTag(section + 6900)
        if expandedSection == -1 {
            expandedSection = section
            expand(section, detail: detail)
        } else {
            if expandedSection == section {
                collapse(section, detail: detail)
            } else {
                let expandedDetail = view.viewWithTag(expandedSection + 6900)
                collapse(expandedSection, detail: expandedDetail)
                expand(section, detail: detail)
            }
        }
    }
    
    func expand(_ section: Int, detail: UIView?) {
        expandedSection = section
//        UIView.animate(withDuration: 0.4) {
            detail?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi) / 2)
//        }
        
        var indexes = [IndexPath]()
        for i in 0..<sectionContent[section].count {
            indexes.append(IndexPath(row: i, section: section))
        }
        tableView.beginUpdates()
        tableView.insertRows(at: indexes, with: .fade)
        tableView.endUpdates()
    }

    func collapse(_ section: Int, detail: UIView?) {
        expandedSection = -1
//        UIView.animate(withDuration: 0.4) {
            detail?.transform = CGAffineTransform(rotationAngle:  0)
//        }
        var indexes = [IndexPath]()
        for i in 0..<sectionContent[section].count {
            indexes.append(IndexPath(row: i, section: section))
        }
        tableView.beginUpdates()
        tableView.deleteRows(at: indexes, with: .fade)
        tableView.endUpdates()
    }
}
