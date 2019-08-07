//
//  TaskTableViewController.swift
//  MyReminder
//
//  Created by alekseykolesnik on 05/08/2019.
//  Copyright © 2019 alekseykolesnik. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications


class TaskTableViewController: UITableViewController {
    
    

    var tasks = [Tasks]()
    
    let dateFormatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "EEEE, dd MMMM, yyyy, HH:mm"
        dateFormatter.locale = Locale(identifier: "ru_Ru")
        
        setupNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = Tasks.fetchRequest()as NSFetchRequest<Tasks>
        
        let sortDescriptor = NSSortDescriptor(key: "taskDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            tasks = try context.fetch(fetchRequest)
        } catch let error {
            print("Не удалось загрузить данные из-за ошибки \(error)")
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellIndentifier", for: indexPath)
        let task = tasks[indexPath.row]
        
        let taskName = task.task ?? ""
        cell.textLabel?.text = taskName.capitalized
        
        if let date = task.taskDate as Date? {
            cell.detailTextLabel?.text = dateFormatter.string(from: date).capitalized
        } else {
            cell.detailTextLabel?.text = " "
        }
        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
        // удаляем ненужные напоминания
        if tasks.count > indexPath.row {
            let task = tasks[indexPath.row]
            
            // Removal notification
            if let identifier = task.taskId {
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: [identifier])
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            context.delete(task)
            tasks.remove(at: indexPath.row)
            
            do {
                try context.save()
            } catch let error {
                print("Не удалось сохранить из-за ошибки: \(error)")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        if #available(iOS 11, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
    
}
