//
//  ViewController.swift
//  part3
//
//  Created by Jason Huang on 6/21/20.
// 110779373
//  Copyright © 2020 Jason Huang. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func addTask(_ className:String) {
        let alert = UIAlertController(title:"Add task for " + className, message:nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Task Name"
        }
        let myDatePicker: UIDatePicker = UIDatePicker()
        myDatePicker.timeZone = .current
        myDatePicker.frame = CGRect(x: 0, y: 15, width: 270, height: 200)
        alert.view.addSubview(myDatePicker)
        let addAction = UIAlertAction(title: "Add", style: .default, handler: { _ in
            let taskName = alert.textFields!.first!.text
            if taskName != nil {
                print(taskName!)
            }
            print("Selected Date: \(myDatePicker.date)")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion:nil)
    }
    
}

func hideAllTaskPastDue(_ tasks: inout [Task]){
    let now = Date()
    for task in tasks{
        if task.date! < now {
            let index = tasks.firstIndex(of: task)
            if index != nil {
                tasks.remove(at: index!)
            }
        }
    }
}
func sortTaskBySettings(_ tasks: inout [Task]) {
    let settings = UserDefaults.standard
    let sort = settings.integer(forKey: "sort")
    let asc = settings.bool(forKey: "asc")
    if asc {
        switch sort {
               case 0:
                   tasks.sort(by: {
                       $0.date!.compare($1.date!) == .orderedAscending
                   })
               case 1:
                   tasks.sort(by: {
                        $0.name!.lowercased() < $1.name!.lowercased()
                   })
               default:
                   tasks.sort(by: {
                       $0.date!.compare($1.date!) == .orderedAscending
                   })
           }
    } else {
        switch sort {
            case 0:
                tasks.sort(by: {
                    $0.date!.compare($1.date!) == .orderedDescending
                })
            case 1:
                tasks.sort(by: {
                    $0.name!.lowercased() > $1.name!.lowercased()
                })
            default:
                tasks.sort(by: {
                    $0.date!.compare($1.date!) == .orderedDescending
                })
        }
    }
}
class HomeViewController: UIViewController {
    
    var tasks = [Task]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad(){
//        tableView.delegate = self
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        do {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            tasks = try PersistentDataService.context.fetch(fetchRequest)
            hideAllTaskPastDue(&tasks)
            sortTaskBySettings(&tasks)
            tableView.reloadData()
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
}
//extension HomeViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("You tapped me")
//    }
//}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    func getWeekDay(_ date:Date)->String{
        let dayForm = DateFormatter()
        dayForm.dateFormat = "EEE"
        let dayYearStr = dayForm.string(from: date)
        return dayYearStr
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "task")
        let taskName = cell?.contentView.viewWithTag(101) as! UILabel
        taskName.text = tasks[indexPath.row].name
        let className = cell?.contentView.viewWithTag(102) as! UILabel
        className.text = tasks[indexPath.row].classTaskName
        let df = DateFormatter()
        df.dateFormat = "MM-dd"
        let dueDate = df.string(from: tasks[indexPath.row].date!)
        
        let date = cell?.contentView.viewWithTag(103) as! UILabel
        date.text = dueDate
        
        let weekDay = cell?.contentView.viewWithTag(104) as! UILabel
        weekDay.text = getWeekDay(tasks[indexPath.row].date!)
        
        return cell!
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            PersistentDataService.context.delete(task)
            PersistentDataService.saveContext()
            tasks.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
}
class AddTaskViewHomeController: UIViewController {
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var taskNameField: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var className = "General"
    
    override func viewDidLoad(){
        super.viewDidLoad()
        categoryLabel.text = "Category: " + className
    }
    
    @IBAction func addFilledTask(_ sender: Any) {
        var taskName = taskNameField.text;
        if taskName == nil {
            taskName = ""
        }
        let date = datePicker.date
        let task = Task(context: PersistentDataService.context)
        task.name = taskName
        task.date = date
        task.classTaskName = className
        PersistentDataService.saveContext()
        navigationController?.popViewController(animated: true)
    }
}
extension UINavigationController {
  func popToViewController(ofClass: AnyClass, animated: Bool = true) {
    if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
      popToViewController(vc, animated: animated)
    }
  }
}
class ClassViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var classes = [Class]()
    var all_tasks = [Task]()
    override func viewDidLoad(){
        tableView.delegate = self
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchClassesTable()
        addGeneralDefaultClass()
    }
    func fetchClassesTable(){
        do {
            let fetchRequest: NSFetchRequest<Class> = Class.fetchRequest()
            classes = try PersistentDataService.context.fetch(fetchRequest)
            tableView.reloadData()
            let taskFetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            all_tasks = try PersistentDataService.context.fetch(taskFetchRequest)
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    func addGeneralDefaultClass() {
        var generalClassExist = false
        for classObj in classes{
            if(classObj.name == "General") {
                generalClassExist = true
                break
            }
        }
        if !generalClassExist {
            let generalClass = Class(context:PersistentDataService.context)
            generalClass.name = "General"
            PersistentDataService.saveContext()
            classes.append(generalClass)
            print("Adding general class because it did not exist")
            tableView.reloadData()
        }
    }
}
extension ClassViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpecificClassTaskViewController") as! SpecificClassTaskViewController
        vc.className = classes[indexPath.row].name!
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ClassViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count
    }
    func getCountNumber(_ className:String)->Int {
        var count = 0
        for task in all_tasks{
            if task.classTaskName == className {
                count += 1
            }
        }
        return count
    }
    func removeAllTaskWithClass(_ className:String) {
        for task in all_tasks{
            if task.classTaskName == className {
                let index = all_tasks.firstIndex(of: task)
                if index != nil {
                    PersistentDataService.context.delete(task)
                    PersistentDataService.saveContext()
                    all_tasks.remove(at: index!)
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "classTask")
        let className = cell?.contentView.viewWithTag(101) as! UILabel
        className.text = classes[indexPath.row].name
        let count = cell?.contentView.viewWithTag(102) as! UILabel
        count.text = String(getCountNumber(classes[indexPath.row].name!))
        return cell!
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
               let classObj = classes[indexPath.row]
               removeAllTaskWithClass(classes[indexPath.row].name!)
               PersistentDataService.context.delete(classObj)
               PersistentDataService.saveContext()
               classes.remove(at: indexPath.row)
               tableView.reloadData()
           }
       }
}
class AddClassViewController: UIViewController {
    @IBOutlet weak var classNameField: UITextField!
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    @IBAction func addClass(_ sender: Any) {
        var className = classNameField.text;
        if className == nil {
            className = ""
        }
        let classObj = Class(context: PersistentDataService.context)
        classObj.name = className
        PersistentDataService.saveContext()
        navigationController?.popToViewController(ofClass: ClassViewController.self)
    }
}

class CalendarViewController: UIViewController {
    override func viewDidLoad(){
        super.viewDidLoad()
    }
}
class SpecificClassTaskViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var class_tasks = [Task]()
    
    var className:String = ""
    override func viewDidLoad(){
        super.viewDidLoad()
        self.navigationItem.title = className
    }
    
    @IBAction func addNewTask(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddTaskViewHomeController") as! AddTaskViewHomeController
        vc.className = className
        navigationController?.pushViewController(vc, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        do {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            class_tasks = try PersistentDataService.context.fetch(fetchRequest)
            for task in class_tasks{
                if task.classTaskName != className {
                    let index = class_tasks.firstIndex(of: task)
                    if index != nil {
                        class_tasks.remove(at: index!)
                    }
                }
            }
            sortTaskBySettings(&class_tasks)
            tableView.reloadData()
        } catch {
            print("Unexpected error: \(error).")
        }
    }
}
extension SpecificClassTaskViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return class_tasks.count
    }
    func getWeekDay(_ date:Date)->String{
        let dayForm = DateFormatter()
        dayForm.dateFormat = "EEE"
        let dayYearStr = dayForm.string(from: date)
        return dayYearStr
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "task")
        let taskName = cell?.contentView.viewWithTag(101) as! UILabel
        taskName.text = class_tasks[indexPath.row].name
        let className = cell?.contentView.viewWithTag(102) as! UILabel
        className.text = class_tasks[indexPath.row].classTaskName
        let df = DateFormatter()
        df.dateFormat = "MM-dd"
        let dueDate = df.string(from: class_tasks[indexPath.row].date!)
        
        let date = cell?.contentView.viewWithTag(103) as! UILabel
        date.text = dueDate
        
        let weekDay = cell?.contentView.viewWithTag(104) as! UILabel
        weekDay.text = getWeekDay(class_tasks[indexPath.row].date!)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = class_tasks[indexPath.row]
            PersistentDataService.context.delete(task)
            PersistentDataService.saveContext()
            class_tasks.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
}

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setSortingSettings(row)
    }
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var sortingLabel: UILabel!
    
    @IBOutlet weak var sortingSwitch: UISwitch!
    var options: Array<String> = ["Date", "Task Name"]
    
    override func viewDidLoad(){
        pickerView.dataSource = self
        pickerView.delegate = self
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        let settings = UserDefaults.standard
        let pick = settings.integer(forKey: "sort")
        let switched = settings.bool(forKey: "asc")
        sortingSwitch.setOn(switched, animated: true)
        if switched {
            sortingLabel.text = "Ascending"
        } else {
            sortingLabel.text = "Descending"
        }
        pickerView.selectRow(pick, inComponent: 0, animated: true)
    }
    func setSortingSettings(_ row:Int){
        let settings = UserDefaults.standard
        settings.set(row,forKey: "sort")
        settings.synchronize()
    }
    @IBAction func onSwitchChannge(_ sender: Any) {
        let settings = UserDefaults.standard
        let switched = sortingSwitch.isOn
        settings.set(switched, forKey: "asc")
        settings.synchronize()
        if switched {
            sortingLabel.text = "Ascending"
        } else {
            sortingLabel.text = "Descending"
        }
    }
}
