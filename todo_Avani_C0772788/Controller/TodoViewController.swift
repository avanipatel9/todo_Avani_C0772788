//
//  TodoViewController.swift
//  todo_Avani_C0772788
//
//  Created by Avani Patel on 6/29/20.
//  Copyright © 2020 Avani Patel. All rights reserved.
//

import UIKit

class TodoViewController: UIViewController {

    var todo: Todo?
    var delegate: TaskListViewController?
    @IBOutlet weak var todoLbl: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var buttonStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if todo == nil {
                    buttonStack.isHidden = true
                }
                if let todoData = todo
                {
                    todoLbl.text = todoData.name
                    datePicker.date = todoData.due_date!
                }
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        if(checkTitle())
        {
            if todo == nil
            {
                delegate?.saveTodo(title: todoLbl!.text!, dueDate: datePicker!.date)
            }
            else
            {
                todo?.name = todoLbl!.text!
                todo?.due_date = datePicker!.date
                delegate?.updateTodo()
            }
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func deleteBtn(_ sender: Any) {
        delegate?.deleteTodoFromList()
        navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func doneBtn(_ sender: Any) {
        if(checkTitle()) {
            todo?.name = todoLbl!.text!
            todo?.due_date = datePicker!.date
            delegate?.markTodoCompleted()
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    func checkTitle() -> Bool {
        if (todoLbl.text?.isEmpty ?? true) {
            let alert = UIAlertController(title: "Title cannot be blank", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else {
            return true
        }
    }
    
    

}
