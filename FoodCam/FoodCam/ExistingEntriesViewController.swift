//
//  ExistingEntriesViewController.swift
//  FoodCam
//
//  Created by Marcin Maciukiewicz on 03/11/2016.
//  Copyright © 2016 Marcin Maciukiewicz. All rights reserved.
//

import UIKit

class ExistingEntriesViewController: UITableViewController {

    fileprivate var dailyEntries:[DailyEntries]? = nil
    
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
        dailyEntries = DataSource().findAllFoodEntries()
        tableView.reloadData()
    }
    
    @IBAction func doEditEntry(_ sender: Any) {
        print("doEditEntry")
    }
    
    @IBAction func doSwipe(_ sender: Any) {
        print("doSwipe")
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
extension ExistingEntriesViewController {
    
//    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let day = dailyEntries?[indexPath.section] else {
//            return
//        }
//        
////        let entry = day.entries[indexPath.row]
////        if let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: "addEntry") as? NewEntryViewController {
////            detailsVC.editMode(entry: entry)
////            navigationController?.pushViewController(detailsVC, animated: true)
////        }
//    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let day = dailyEntries?[indexPath.section] else {
            return
        }
        
        let entry = day.entries[indexPath.row]
        if let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: "addEntry") as? NewEntryViewController {
            detailsVC.editMode(entry: entry)
            navigationController?.pushViewController(detailsVC, animated: true)
        }

    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let day = dailyEntries?[indexPath.section] {
                let entry = day.entries[indexPath.row]
                do {
                    try DataSource().delete(foodEntry: entry)
                    dailyEntries = DataSource().findAllFoodEntries()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } catch let error as NSError {
                    print(error)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ExistingEntriesViewController {

    public override func numberOfSections(in tableView: UITableView) -> Int {
        guard let e = dailyEntries else {
            return 1
        }
        
        return e.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let de = dailyEntries else {
            return 0
        }
        
        let e = de[section].entries
        return e.count
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let e = dailyEntries else {
            return nil
        }
        
        let result:String?
        
        let date = e[section].date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        result = dateFormatter.string(from: date)
        
        return result
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellID = "EntryDetails"
        let result = tableView.dequeueReusableCell(withIdentifier: cellID)
//        if (result == nil) {
//            result = UITableViewCell(style: .default, reuseIdentifier: cellID)
//        }
        
        if let day = dailyEntries?[indexPath.section] {
            let entry = day.entries[indexPath.row]
            result?.textLabel?.text = "\(entry.createdAt)"
        }
        
        
        return result!
        
    }
    
}
