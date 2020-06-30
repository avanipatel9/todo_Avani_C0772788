//
//  MoveTodoViewController.swift
//  todo_Avani_C0772788
//
//  Created by Avani Patel on 6/29/20.
//  Copyright © 2020 Avani Patel. All rights reserved.
//

import UIKit
import CoreData

class MoveTodoViewController: UIViewController {

    var categories = [Category]()
       var selectedTodo: [Todo]? {
           didSet {
               loadCategories()
           }
       }
    let moveTodoContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
       
    }
    

    @IBAction func cancelBtn(_ sender: Any) {
           dismiss(animated: true, completion: nil)
       }
       

}

extension MoveTodoViewController {
    func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        let categoryPredicate = NSPredicate(format: "NOT name MATCHES %@", selectedTodo?[0].parentFolder?.name ?? "")
        request.predicate = categoryPredicate
        
        do {
            categories = try moveTodoContext.fetch(request)
        } catch {
            print("Error  \(error.localizedDescription)")
        }
    }
}

extension MoveTodoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "")
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            for todo in self.selectedTodo! {
                todo.parentFolder = self.categories[indexPath.row]
            }
            self.performSegue(withIdentifier: "goBackToTaskList", sender: self)
        
    }
}
