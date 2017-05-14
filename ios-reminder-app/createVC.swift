//
//  createVC.swift
//  ios-reminder-app
//
//  Created by William Guo on 13/5/17.
//  Copyright © 2017 William Guo. All rights reserved.
//

import UIKit
import CoreData

class createVC: UIViewController {

    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var addNotesLabel: UILabel!
    @IBOutlet weak var reminderText: UITextField!
    @IBOutlet weak var addNotesText: UITextView!
    
    var chosenReminderID:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (chosenReminderID != 0) {
            print(chosenReminderID)
            // predicate
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminder")
            fetchRequest.predicate = NSPredicate(format: "id = %d", chosenReminderID)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    print("----- successfully retrieved specific object from coredata")
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            reminderText.text = name
                        }
                        if let notes = result.value(forKey: "notes") as? String {
                            addNotesText.text = notes
                        }
                    }
                }
            } catch {
                print("Error fetching specified object from coredata")
            }
        }

        // Do any additional setup after loading the view.
    }

    @IBAction func saveButtonClicked(_ sender: Any) {
        let pid = UserDefaults.standard.object(forKey: "reminderPID") as? Int
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newReminder = NSEntityDescription.insertNewObject(forEntityName: "Reminder", into: context)
        newReminder.setValue(reminderText.text, forKey: "name")
        newReminder.setValue(addNotesText.text, forKey: "notes")
        newReminder.setValue(pid, forKey: "id")

        UserDefaults.standard.set((pid! + 1), forKey: "reminderPID")
        UserDefaults.standard.synchronize()
        do {
            try context.save()
            
            print("Save Successful")
        } catch {
            print("Error: could not save")
        }
    }
    

}
