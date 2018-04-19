//
//  TagTableViewController.swift
//  urban-waddle
//
//  Created by Jonah Zukosky on 4/19/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit

class TagTableViewController: UITableViewController {

    let savedSelectedTags = UserDefaults.standard
    let tags: [String] = ["tag1","tag2","tag3","tag4","tag5","tag6"]
    var selectedTags: [String] = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedTags = savedSelectedTags.stringArray(forKey: "SavedTagArray") ?? [String]()
        

    }
    override func viewDidDisappear(_ animated: Bool) {
        savedSelectedTags.set(selectedTags, forKey: "SavedTagArray")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath)
        cell.textLabel?.text = tags[indexPath.row]
        cell.accessoryType = selectedTags.contains(tags[indexPath.row]) ? .checkmark : .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if self.selectedTags.contains(tags[indexPath.row]) {
            selectedTags = selectedTags.filter{$0 != tags[indexPath.row]}
        }else {
            selectedTags.append(tags[indexPath.row])
        }
        tableView.reloadData()
    }
}
