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
        var id : Int
        var name : String
    }
    
    var reminderArray = [reminder]()
    
    var selectedReminderID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        // set primary key if not exists
        if (UserDefaults.standard.object(forKey: "reminderPID") == nil) {
            UserDefaults.standard.set(0, forKey: "reminderPID")
            UserDefaults.standard.synchronize()
        }
        
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
                    if let id = result.value(forKey: "id") as? Int {
                        let name = result.value(forKey: "name") as? String
                        let object = reminder(id: id, name: name!)
                        self.reminderArray.append(object)
                        print(id)
                        print(name!)
                    }
                    
                    self.tableView.reloadData()
                }
            }
        } catch {
            print("Error fetching from coreData")
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
        self.selectedReminderID = reminderArray[indexPath.row].id
        performSegue(withIdentifier: "toCreateVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toCreateVC") {
            let destinationVC = segue.destination as! createVC
            destinationVC.chosenReminderID = selectedReminderID
        }
    }

    @IBAction func addButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toCreateVC", sender: nil)
    }

    @IBAction func editButtonClicked(_ sender: Any) {
//        if (self.tableView.isEditing){
//            self.tableView.isEditing = false
////            self.editButtonItem.title = "Edit"
//        } else {
//            self.tableView.isEditing = true
////            self.editButtonItem.title = "Done"
//        }
        print ("clear button clicked")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminder")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if (results.count > 0) {
                for result in results as! [NSManagedObject] {
                    context.delete(result)
                }
            }
        } catch {
            print("Error fetching from coreData")
        }
        do {
            try context.save()
            self.tableView.reloadData()
        } catch {
            print ("Error saving delete operation")
        }

    }
}

