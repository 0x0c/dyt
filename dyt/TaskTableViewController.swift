//
//  TaskTableViewController.swift
//  dyt
//
//  Created by Akira Matsuda on 2018/02/03.
//  Copyright © 2018 Akira Matsuda. All rights reserved.
//

import UIKit
import RealmSwift
import MZFormSheetPresentationController

class TaskTableViewController: UITableViewController {
	
	var tasks : [Task] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.addNewTask(gestureRecognizer:)));
		let backgroundView = UIView(frame: self.tableView.bounds)
		self.tableView.backgroundView = backgroundView
		self.tableView.backgroundView!.addGestureRecognizer(tapGesture)
		self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0)
		self.tableView.separatorStyle = .none
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UpdateTask"), object: nil, queue: OperationQueue.main) { (_) in
			self.refresh()
		}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let row = self.tableView.indexPathForSelectedRow {
			self.tableView.deselectRow(at: row, animated: true)
		}
		self.refresh()
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") as! TaskCell
        // Configure the cell...
		let t = self.tasks[indexPath.row]
		cell.taskLabel.text = t.title
		if let date = t.until {
			cell.dateLabel.isHidden = false
			cell.dateLabel.text = String.mediumDateNoTime(date: date)
		}
		else {
			cell.dateLabel.isHidden = true
		}
		
        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive,
											  title: "Delete",
											  handler: { (action: UIContextualAction, view: UIView, completion: (Bool) -> Void) in
												TaskManager.deleteTask(self.tasks[indexPath.row])
												self.tasks.remove(at: indexPath.row)
												self.tableView.deleteRows(at: [indexPath], with: .left)
												completion(true)
		})
		deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.2352941176, blue: 0.1882352941, alpha: 1)
		
		return UISwipeActionsConfiguration(actions: [deleteAction])
	}
	
	override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let doneAction = UIContextualAction(style: .normal,
												title: "Done",
												handler: { (action: UIContextualAction, view: UIView, completion: (Bool) -> Void) in
													completion(true)
		})
		doneAction.backgroundColor = #colorLiteral(red: 0, green: 0.4577052593, blue: 1, alpha: 1)
		
		return UISwipeActionsConfiguration(actions: [doneAction])
	}
	
	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return .none
	}
	
	// MARK: -
	
	@objc func addNewTask(gestureRecognizer: UITapGestureRecognizer) {
		let formSheetController = MZFormSheetPresentationViewController.init(contentViewController: UINavigationController(rootViewController: NewTaskViewController()))
		formSheetController.contentViewCornerRadius = 15
		formSheetController.presentationController?.movementActionWhenKeyboardAppears = .moveToTopInset
		formSheetController.presentationController?.contentViewSize = CGSize(width: self.view.frame.width * 0.85, height: 735 / 2)
		formSheetController.presentationController?.shouldCenterVertically = true
		formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
		formSheetController.presentationController?.blurEffectStyle = .dark
		formSheetController.contentViewControllerTransitionStyle = .slideFromBottom
		self.present(formSheetController, animated: true, completion: nil)
	}
	
	func refresh() {
		self.tasks = Array(TaskManager.tasks().inProgress().sorted(byKeyPath: "created", ascending: false))
		self.tableView.reloadData()
	}
}
