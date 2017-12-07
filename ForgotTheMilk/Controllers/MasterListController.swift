//
//  MasterListController.swift
//  ForgotTheMilk
//
//  Created by Angus Muller on 28/11/2017.
//  Copyright © 2017 Angus Muller. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation


class MasterListController: UITableViewController {
    
    
    let managedObjectContext = CoreDataStack().managedObjectContext
    
    lazy var dataSource: MasterListDataSource = {
        return MasterListDataSource(tableView: self.tableView, context: managedObjectContext)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.managedObjectContext = managedObjectContext
            appDelegate.mainVCDelegate = self
        }
        
        tableView.rowHeight = 120
        tableView.dataSource = dataSource
        
        let manager = CLLocationManager()
        print("Count: \(manager.monitoredRegions.count)")
        
    }

    override func viewDidAppear(_ animated: Bool) {
        emptyTablePlaceholder() // show default text when tableview is empty
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let reminder = dataSource.fetchedResultsController.object(at: indexPath)
        
        if reminder.isActive {
            let deactivateAction = UITableViewRowAction(style: .normal, title: "Deactivate", handler: { (rowAction, indexPath) in
                reminder.isActive = false
                self.managedObjectContext.saveChanges()
                LocationManager.removeMonitoringOfReminder(objectID: reminder.objectID)
            })
            
            let deleteAction = UITableViewRowAction(style: .normal, title: "Delete", handler: { (rowAction, indexPath) in
                self.managedObjectContext.delete(reminder)
                self.managedObjectContext.saveChanges()
                LocationManager.removeMonitoringOfReminder(objectID: reminder.objectID)

            })
            deactivateAction.backgroundColor = .blue
            deleteAction.backgroundColor = .red
            return [deactivateAction, deleteAction]
        } else {
            /* Addtional feature for future
            let activateAction = UITableViewRowAction(style: .normal, title: "Activate", handler: { (rowAction, indexPath) in
                reminder.isActive = true
                self.managedObjectContext.saveChanges()
                self.dataSource.fetchedResultsController.tryFetch()
                tableView.reloadData()
            })
 */
            let deleteAction = UITableViewRowAction(style: .normal, title: "Delete", handler: { (rowAction, indexPath) in
                self.managedObjectContext.delete(reminder)
                self.managedObjectContext.saveChanges()

            })
            //activateAction.backgroundColor = .blue
            deleteAction.backgroundColor = .red
            
            return [deleteAction]
        }
        
 
    }
 

 
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newReminder" {
            let newReminderController = segue.destination as! DetailReminderController
            newReminderController.managedObjectContext = self.managedObjectContext // send referance of context
        } else if segue.identifier == "showDetail" {
            guard let detailsViewController = segue.destination as? DetailReminderController, let indexPath = tableView.indexPathForSelectedRow else { return }
            
            let reminder = dataSource.object(at: indexPath)
            detailsViewController.currentReminder = reminder // pass over selected reminder data
            detailsViewController.managedObjectContext = self.managedObjectContext // send referance of context
        }
    }
    
    
    

}

// show default text when tableview is empty
extension MasterListController {
    func emptyTablePlaceholder(){
        if self.tableView.visibleCells.isEmpty {
            tableView.tableFooterView = UIView(frame: CGRect.zero)
          //  tableView.backgroundColor = UIColor.clearColor()
            
            let label = UILabel()
            label.frame.size.height = 42
            label.frame.size.width = (tableView.frame.size.width-10)
            label.center = tableView.center
            label.center.y = (tableView.frame.size.height/2.4)
            label.numberOfLines = 0
            label.textColor = UIColor.white
            label.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.light)
            label.text = "You haven't added any Reminders yet! \nDon't forget to add the milk!"
            label.textAlignment = .center
            label.tag = 1
            
            
            self.tableView.addSubview(label)
            
        }else{
            self.tableView.viewWithTag(1)?.removeFromSuperview()
        }
    }
}

extension MasterListController: NotificationFromAppDelegate {
    func updateContext() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.managedObjectContext = managedObjectContext
        }
    }
    
    func updateTableView() {
            dataSource.fetchedResultsController.tryFetch()
            tableView.reloadData()
            print("tableview updated")
    }
    
    
}
