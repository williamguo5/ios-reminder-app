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
        
//        UserDefaults.standard.removeObject(forKey: "reminderID")
//        UserDefaults.standard.removeObject(forKey: "reminderOrder")
        // set primary key if not exists
        
        retrieveInfo()
    }
    
    func retrieveInfo() {
        reminderArray.removeAll()
        
//        print ("printing order")
//        if let orderArray = UserDefaults.standard.object(forKey: "reminderOrder") as? [Int] {
//            for id in orderArray {
//                print(id)
//            }
//        }
//        print ("end order")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminder")
        fetchRequest.returnsObjectsAsFaults = false
        
        var reminders = [Int:String]()
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if (results.count > 0) {
                for result in results as! [NSManagedObject] {
                    if let id = result.value(forKey: "id") as? Int {
                        let name = result.value(forKey: "name") as? String
                        reminders[id] = name!
                        
                    }
                }
            }
        } catch {
            print("Error fetching from coreData")
        }
        
        // inserting in ordering
        if let reminderOrder = UserDefaults.standard.object(forKey: "reminderOrder") as? [Int] {
            for id in reminderOrder {
                let object = reminder(id: id, name: reminders[id]!)
                reminderArray.append(object)
                self.tableView.reloadData()
                print("id is: \(id)")
                print("name is: \(reminders[id]!)")
//                print(id)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(tableVC.retrieveInfo), name: NSNotification.Name(rawValue: "reminderCreated"), object: nil)
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let id = reminderArray[indexPath.row].id
            print ("deleing reminder with id: \(id)")
            reminderArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
    
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminder")
            fetchRequest.predicate = NSPredicate(format: "id = %d", id)
            fetchRequest.returnsObjectsAsFaults = false
    
            do {
                let results = try context.fetch(fetchRequest)
    
                if (results.count > 0) {
                    for result in results as! [NSManagedObject] {
                        context.delete(result)
                    }
                    try context.save()
                }
            } catch {
                print("Error fetching from coreData")
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = reminderArray[sourceIndexPath.row]
        reminderArray.remove(at: sourceIndexPath.row)
        reminderArray.insert(itemToMove, at: destinationIndexPath.row)
        if var reminderOrder = UserDefaults.standard.object(forKey: "reminderOrder") as? [Int] {
            reminderOrder.remove(at: sourceIndexPath.row)
            reminderOrder.insert(itemToMove.id, at: destinationIndexPath.row)
            UserDefaults.standard.set(reminderOrder, forKey: "reminderOrder")
            UserDefaults.standard.synchronize()
        }
    }
    // helper function to save array order in userdefaults
    
    @IBAction func editButtonClicked(_ sender: Any) {
        
        if (self.tableView.isEditing){
            self.tableView.isEditing = false
            self.navigationItem.leftBarButtonItem?.title = "Edit"
        } else {
            self.tableView.isEditing = true
            self.navigationItem.leftBarButtonItem?.title = "Done"
        }
        print ("edit button clicked")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toCreateVC") {
            let destinationVC = segue.destination as! createVC
            destinationVC.chosenReminderID = selectedReminderID
        }
    }    
    
    @IBAction func addButtonClicked(_ sender: Any) {
        selectedReminderID = 0
        performSegue(withIdentifier: "toCreateVC", sender: nil)
    }
    
}

