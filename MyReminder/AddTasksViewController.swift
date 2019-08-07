//
//  ViewController.swift
//  MyReminder
//
//  Created by alekseykolesnik on 05/08/2019.
//  Copyright © 2019 alekseykolesnik. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications


class AddTasksViewController: UIViewController {

    
    @IBOutlet weak var tasksTextField: UITextField!
    @IBOutlet weak var datePickerOutlet: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePickerOutlet.minimumDate = Date()
        
        setupNavigationBar()
        
    }


    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        
        let tasks = tasksTextField.text ?? ""
        
        // Получение времени установки напоминания
        let taskDate = datePickerOutlet.date
        
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newTask = Tasks(context: context)
        newTask.task = tasks
        newTask.taskDate = taskDate as Date
        newTask.taskId = UUID().uuidString
        
        if let uniqueId = newTask.taskId {
            print("new task id \(uniqueId)")
        }
        
        do {
            try context.save()
            
            // Notification
            let message = "Не забудь: \(tasks.capitalized)!!!"
            let content = UNMutableNotificationContent()
            content.body = message
            content.sound = UNNotificationSound.default
            let dateComponents = Calendar.current.dateComponents([.month, .day, .hour, .minute], from: taskDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            if let identifier = newTask.taskId {
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                let center = UNUserNotificationCenter.current()
                center.add(request, withCompletionHandler: nil)
            }
        } catch let error {
            print("Не удалось сохранить из-за ошибки \(error)")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        if #available(iOS 11, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
    
}

