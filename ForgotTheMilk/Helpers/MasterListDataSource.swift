//
//  MasterListDataSource.swift
//  ForgotTheMilk
//
//  Created by Angus Muller on 28/11/2017.
//  Copyright © 2017 Angus Muller. All rights reserved.
//

import Foundation

import UIKit
import CoreData

class MasterListDataSource: NSObject, UITableViewDataSource {
    private let tableView: UITableView
    private let managedObjectContext: NSManagedObjectContext
    
    // Use fetched results controller
    lazy var fetchedResultsController: ReminderFetchedResultsController = {
        return ReminderFetchedResultsController(managedObjectContext: self.managedObjectContext, tableView: self.tableView)
    }()
    
    init(tableView: UITableView, context: NSManagedObjectContext) {
        self.tableView = tableView
        self.managedObjectContext = context
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = fetchedResultsController.sections?[section] else { return nil }
        return section.name
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReminderCell.reuseIdentifier, for: indexPath) as! ReminderCell
        
        let reminder = fetchedResultsController.object(at: indexPath)
        let viewModel = ReminderCellViewModel(reminder: reminder) // get viewmodel of cell
        
        cell.configure(with: viewModel) // Pass viewmodel of cell to cell view
        
        return cell
    }
    
    // Set action for delete button
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let entry = fetchedResultsController.object(at: indexPath)
        managedObjectContext.delete(entry)
        managedObjectContext.saveChanges()
    }
    
    // Helper to return configured cell
    
    
    func object(at indexPath: IndexPath) -> Reminder {
        return fetchedResultsController.object(at: indexPath)
    }
    
   
    
}


