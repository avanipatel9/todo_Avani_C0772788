//
//  ViewController.swift
//  todo_Avani_C0772788
//
//  Created by Avani Patel on 6/29/20.
//  Copyright © 2020 Avani Patel. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class ViewController: UIViewController {

    @IBOutlet weak var tabelView: UITableView!
    var categoryContext: NSManagedObjectContext!
    var notificationArray = [ToDo]()
    
    var categoryName = UITextField()
    var categoryArray: [Category] = [Category]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCoreData()
        setUpTableView()
        firstTimeSetup()
        setUpNotifications()
    }
    

    @IBAction func addCategory(_ sender: Any) {
         let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
         alert.addTextField(configurationHandler: addCategoryName(textField:))
         alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
             if(self.categoryName.text!.count < 1) {
                 self.emptyFieldAlert()
                 return
             }
             else {
                 self.addNewCategory()
             }
         }))
         alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
         self.present(alert, animated: true, completion: nil)
     }
     
     
     func emptyFieldAlert() {
         
         let alert = UIAlertController(title: "Alert", message: " Category Name cannot be empty", preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
         self.present(alert, animated: true, completion: nil)
         
     }
     
     func addCategoryName(textField: UITextField) {
         
         self.categoryName = textField
         self.categoryName.placeholder = " Please Enter Category Name"
         
     }
}

extension ViewController{
    
    func initializeCoreData() {
        print("initialized")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        categoryContext = appDelegate.persistentContainer.viewContext
        
        fetchCategoryData()
        
    }
     func firstTimeSetup() {
            let categoryNames = self.categoryArray.map {$0.name}
            guard !categoryNames.contains("Archived") else {return}
            let newCategory = Category(context: self.categoryContext)
            newCategory.name = "Archived"
            self.categoryArray.append(newCategory)
            do {
                try categoryContext.save()
                tabelView.reloadData()
            } catch {
                print("Error  \(error.localizedDescription)")
            }
        }
    
     func fetchCategoryData() {
    
             let request: NSFetchRequest<Category> = Category.fetchRequest()
             let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
     
             request.sortDescriptors = [sortDescriptor]
             do {
                 categoryArray = try categoryContext.fetch(request)
             } catch {
                 print("Error loading categories: \(error.localizedDescription)")
             }
     
             tabelView.reloadData()
             
         }
    
    func addNewCategory() {
        
        let categoryNames = self.categoryArray.map {$0.name}
        guard !categoryNames.contains(categoryName.text) else {self.showAlert(); return}
        let newCategory = Category(context: self.categoryContext)
        newCategory.name = categoryName.text!
        self.categoryArray.append(newCategory)
        do {
            try categoryContext.save()
            tabelView.reloadData()
        } catch {
            print("Error saving categories \(error.localizedDescription)")
        }
        
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Same Category Already Exists!", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
              let destination = segue.destination as! TaskListViewController
              if let indexPath = tabelView.indexPathForSelectedRow {
                  destination.selectedCategory = categoryArray[indexPath.row]
              }
          }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func setUpTableView() {
               tabelView.delegate = self
               tabelView.dataSource = self
       
               tabelView.estimatedRowHeight = 44
               tabelView.rowHeight = UITableView.automaticDimension
           }
               
           
           func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
               return categoryArray.count
           }
           
           func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
               let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
               let category = categoryArray[indexPath.row]
               if category.name == "Archived" {
                   cell.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
               }
               cell.textLabel?.text = category.name
               
               return cell
           }
       
       
       func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
           let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
               
                   self.categoryContext.delete(self.categoryArray[indexPath.row])
                   self.categoryArray.remove(at: indexPath.row)
                   do {
                       try self.categoryContext.save()
                   } catch {
                       print("Error  \(error.localizedDescription)")
                   }
                   
                   //        reloads data
                   self.tabelView.reloadData()
                   completion(true)
           }
           
           delete.backgroundColor = #colorLiteral(red: 0.6008332166, green: 0.1533286675, blue: 0.6352941176, alpha: 1)
           delete.image = UIImage(systemName: "trash.fill")
           return UISwipeActionsConfiguration(actions: [delete])
       }
       
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           performSegue(withIdentifier: "noteListScreen", sender: self)
       }
}

extension ViewController {
   // task notification
    func setUpNotifications() {
            
            checkDueTasks()
            if notificationArray.count > 0 {
                for task in notificationArray {
                    
                    if let name = task.name {
                        let notificationCenter = UNUserNotificationCenter.current()
                        let notificationContent = UNMutableNotificationContent()
                        
                        notificationContent.title = "Reminder"
                        notificationContent.body = " \(name) is due tommorow"
                        notificationContent.sound = .default
                        let fromDate = Calendar.current.date(byAdding: .day, value: -1, to: task.due_date!)!
                        let components = Calendar.current.dateComponents([.month, .day, .year], from: fromDate)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                        let request = UNNotificationRequest(identifier: "\(name)taskid", content: notificationContent, trigger: trigger)
                        notificationCenter.add(request) { (error) in
                            if error != nil {
                                print(error ?? " error")
                            }
                        }
                    }
                }
            }
            
        }
        
    
        func checkDueTasks() {
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let request: NSFetchRequest<ToDo> = ToDo.fetchRequest()
            do {
                let notifications = try context.fetch(request)
                for task in notifications {
                    if Calendar.current.isDateInTomorrow(task.due_date!) {
                        notificationArray.append(task)
                    }
                }
            } catch {
                print("Error  \(error.localizedDescription)")
            }
            
        }
}
