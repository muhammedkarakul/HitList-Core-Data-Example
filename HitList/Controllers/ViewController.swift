//
//  ViewController.swift
//  HitList
//
//  Created by Muhammed Karakul on 7.10.2019.
//  Copyright © 2019 Muhammed Karakul. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Properties
class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    private var people: [NSManagedObject] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
}

// MARK: - App Lifecycle
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureApperance()
        linkInteractors()
        registerClasses()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetch()
    }
}

// MARK: - Functions
extension ViewController {
    
    private func linkInteractors() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configureApperance() {
        title = "The List"
    }
    
    private func registerClasses() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    @IBAction func addName(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                return
            }
            
            self.save(name: nameToSave)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField(configurationHandler: nil)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - CoreData Functions
    private func save(name: String) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {
            return
        }
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext) else {
            return
        }
        
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        
        person.setValue(name, forKey: "name")
        
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private func fetch() {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {
            return
        }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    private func remove(by indexPath: IndexPath) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {
            return
        }

        managedContext.delete(people[indexPath.row])
        
        do {
            try managedContext.save()
            fetch()
        } catch let error as NSError {
            print("Could not removed. \(error), \(error.userInfo)")
        }
    }
    
    private func update(name: String, by indexPath: IndexPath) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {
            return
        }
        
        let person = managedContext.object(with: people[indexPath.row].objectID)
        
        person.setValue(name, forKey: "name")
        
        do {
            try managedContext.save()
            fetch()
        } catch let error as NSError {
            print("Could not removed. \(error), \(error.userInfo)")
        }
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            remove(by: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Update Name", message: "Update selected name.", preferredStyle: .alert)
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
            guard let textField = alert.textFields?.first,
                let nameToUpdate = textField.text else {
                    return
            }
            
            self.update(name: nameToUpdate, by: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField(configurationHandler: nil)
        
        alert.addAction(updateAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = people[indexPath.row].value(forKey: "name") as? String
        
        return cell
    }
}
