//
//  SavedViewController.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 3/22/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit
import CoreData

class SavedViewController: UIViewController {

    @IBOutlet weak var savedTable: UITableView!
    
    var savedRestaurants: [Restaurant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Restaurant")
        request.returnsObjectsAsFaults = false
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let results = try context.fetch(request)
            for restaurant in results as! [Restaurant] {
                savedRestaurants.append(restaurant)
            }
        } catch {
            print("Failed to load data")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SavedViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedRestaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath)
        let restaurant = savedRestaurants[indexPath.row]
        cell.textLabel?.text = restaurant.name
        return cell
    }
}

extension SavedViewController: UITableViewDelegate {
    
}
