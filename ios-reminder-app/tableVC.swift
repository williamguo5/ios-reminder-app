//
//  tableVC.swift
//  ios-reminder-app
//
//  Created by William Guo on 12/5/17.
//  Copyright © 2017 William Guo. All rights reserved.
//

import UIKit
import CoreData

class tableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    struct reminder {
        var objectURI : URL
        var name : String
    }
    
    var reminderArray = [reminder]()
    
    var selectedReminderURI = URL(string: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        retrieveInfo()
    }
    
    func retrieveInfo() {
        self.reminderArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminder")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if (results.count > 0) {
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        let object = reminder(objectURI: result.objectID.uriRepresentation(), name: name)
                        self.reminderArray.append(object)
                        
                        print (name)
                        print (result.objectID.uriRepresentation())
                    }
                    
                    self.tableView.reloadData()
                }
            }
        } catch {
            print("Error fetching from coreDate")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = reminderArray[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminderArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedReminderURI = reminderArray[indexPath.row].objectURI
        performSegue(withIdentifier: "toCreateVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toCreateVC") {
            let destinationVC = segue.destination as! createVC
            destinationVC.chosenReminderURI = selectedReminderURI
        }
    }

    @IBAction func addButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toCreateVC", sender: nil)
    }

}

