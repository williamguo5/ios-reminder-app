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
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var chosenReminderID:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retreiveInfo()
    }
    
    func retreiveInfo() {
        
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
                        } else {
                            reminderText.text = ""
                        }
                        if let notes = result.value(forKey: "notes") as? String {
                            addNotesText.text = notes
                        } else {
                            reminderText.text = ""
                        }
                        
                        var strDate = ""
                        if let date = result.value(forKey: "date") as? Date {
                            let dateFormatter = DateFormatter()
                            dateFormatter.locale = Locale(identifier: "en_AU")
                            dateFormatter.setLocalizedDateFormatFromTemplate("EdMMM hh:mm a")
                            strDate = dateFormatter.string(from: date)
                            dateLabel.text = "Date: \(strDate)"
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // new button was clicked, therefore create new object
        if (chosenReminderID == 0) {
            let id : Int
            if (UserDefaults.standard.object(forKey: "reminderID") == nil) {
                id = 1
            } else {
                id = UserDefaults.standard.object(forKey: "reminderID") as! Int
            }
            let newReminder = NSEntityDescription.insertNewObject(forEntityName: "Reminder", into: context)
            newReminder.setValue(reminderText.text, forKey: "name")
            newReminder.setValue(addNotesText.text, forKey: "notes")
            newReminder.setValue(id, forKey: "id")
            
            var order : [Int]
            if (UserDefaults.standard.object(forKey: "reminderOrder") == nil){
                order = [Int]()
            } else {
                order = UserDefaults.standard.object(forKey: "reminderOrder") as! [Int]
            }
            
            order.append(id)
            UserDefaults.standard.set(order, forKey: "reminderOrder")
            UserDefaults.standard.set((id + 1), forKey: "reminderID")
            UserDefaults.standard.synchronize()
            
        } else {
            // previous reminder object selected, therefore update object

            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminder")
            fetchRequest.predicate = NSPredicate(format: "id = %d", chosenReminderID)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if (results.count > 0) {
                    for result in results as! [NSManagedObject] {
                        result.setValue(reminderText.text, forKey: "name")
                        result.setValue(addNotesText.text, forKey: "notes")
                        result.setValue(datePicker.date, forKey: "date")
                    }
                }
            } catch {
                print("Error fetching from coreData")
            }
        }
        
        do {
            try context.save()
            
            print("Save Successful")
        } catch {
            print("Error: could not save")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reminderCreated"), object: nil)
        self.navigationController?.popViewController(animated: true)

    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_AU")
        dateFormatter.setLocalizedDateFormatFromTemplate("EdMMM hh:mm a")
        let strDate = dateFormatter.string(from: datePicker.date)
        dateLabel.text = "Date: \(strDate)"
    }
    

}
