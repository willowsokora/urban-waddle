//
//  DiscoveryViewController.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 3/22/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit

class DiscoveryViewController: UIViewController {

    @IBOutlet weak var discoveryTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        discoveryTable.dataSource = self
        discoveryTable.delegate = self
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

extension DiscoveryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "discoverCell", for: indexPath)
        return cell
    }
}

extension DiscoveryViewController: UITableViewDelegate {
    
}
