//
//  ExistingEntriesViewController.swift
//  FoodCam
//
//  Created by Marcin Maciukiewicz on 03/11/2016.
//  Copyright © 2016 Marcin Maciukiewicz. All rights reserved.
//

import UIKit

class ExistingEntriesViewController: UIViewController {

    fileprivate var entries:[DailyEntries]? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        doRefresh(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doRefresh(_ sender: Any) {
        entries = DataSource().findAllFoodEntries()
        tableView.reloadData()
    }
    
    @IBAction func doEditEntry(_ sender: Any) {
        print("doEditEntry")
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

// MARK: - UITableViewDelegate
extension ExistingEntriesViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let day = entries?[indexPath.section] else {
            return
        }
        
        let entry = day.entries[indexPath.row]
        if let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: "addEntry") as? NewEntryViewController {
            detailsVC.editMode(entry: entry)
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
    
}

// MARK: - UITableViewDataSource
extension ExistingEntriesViewController: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let e = entries else {
            return 0
        }
        
        return e.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellID = "EntryDetails"
        var result = tableView.dequeueReusableCell(withIdentifier: cellID)
        if (result == nil) {
            result = UITableViewCell(style: .default, reuseIdentifier: cellID)
        }
        
        if let day = entries?[indexPath.section] {
            let entry = day.entries[indexPath.row]
            result?.textLabel?.text = "\(entry.createdAt)"
        }
        
        
        return result!
        
    }
    
}