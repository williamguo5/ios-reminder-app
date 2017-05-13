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
    
    var chosenReminderURI = URL(string: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (chosenReminderURI != URL(string: "")) {
            print(chosenReminderURI)
        }

        // Do any additional setup after loading the view.
    }

    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newReminder = NSEntityDescription.insertNewObject(forEntityName: "Reminder", into: context)
        newReminder.setValue(reminderText.text, forKey: "name")
        newReminder.setValue(addNotesText.text, forKey: "notes")
        
        do {
            try context.save()
            print("Save Successful")
        } catch {
            print("Error: could not save")
        }
    }
    

}
