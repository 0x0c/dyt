//
//  EditTaskViewController.swift
//  dyt
//
//  Created by Akira Matsuda on 2018/02/05.
//  Copyright © 2018 Akira Matsuda. All rights reserved.
//

import UIKit
import Former

class EditTaskViewController: FormViewController {
	var task: Task
	var temporallyTask = Task()
	
	private lazy var untilRow: SelectorDatePickerRowFormer = { () -> SelectorDatePickerRowFormer<FormSelectorDatePickerCell> in
		let untilRow = SelectorDatePickerRowFormer<FormSelectorDatePickerCell> {
			$0.titleLabel.text = "Until"
			}.displayTextFromDate(String.mediumDateNoTime)
			.onDateChanged { [weak self] (date) in
				self?.temporallyTask.until = date
		}
		untilRow.selectorView.datePickerMode = .date
		if let date = self.task.until {
			untilRow.date = date
			untilRow.selectorView.date = date
		}
		return untilRow
	}()
	
	init(_ task: Task) {
		self.task = task
		self.temporallyTask.title = self.task.title
		self.temporallyTask.until = self.task.until ?? nil
		self.temporallyTask.note = self.task.note
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		self.title = "Edit Task"
		let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.updateTask))
		let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancel))
		self.navigationItem.rightBarButtonItem = saveButton
		self.navigationItem.leftBarButtonItem = cancelButton
		
		let createHeader: (() -> ViewFormer) = {
			return CustomViewFormer<FormHeaderFooterView>()
				.configure {
					$0.viewHeight = 20
			}
		}
		
		let titleRow = TextFieldRowFormer<FormTextFieldCell>() {
			$0.textField.textColor = .formerColor()
			$0.textField.font = .systemFont(ofSize: 18)
			}.configure { [weak self] in
				$0.placeholder = "Title"
				$0.text = self?.task.title
			}.onTextChanged { [weak self] (text) in
				self?.temporallyTask.title = text
		}
		former.append(sectionFormer: SectionFormer(rowFormer: titleRow).set(headerViewFormer: createHeader()))
		
		let moreRow = SwitchRowFormer<FormSwitchCell>() {
			$0.titleLabel.text = "Add due date"
			}.configure { [weak self] in
				if self?.task.until != nil {
					$0.switched = true
				}
				$0.switchWhenSelected = true
		}
		var rows = [RowFormer]()
		moreRow.onSwitchChanged { [weak self] in
			self?.switchDueDateRow($0, rowFormer: moreRow, selectRow: true)
		}
		rows.append(moreRow)
		if self.task.until != nil {
			rows.append(self.untilRow)
		}
		former.append(sectionFormer: SectionFormer(rowFormers: rows).set(headerViewFormer: createHeader()))
		
		let noteRow = TextViewRowFormer<FormTextViewCell>() {
			$0.textView.textColor = .formerSubColor()
			$0.textView.font = .systemFont(ofSize: 15)
			}.configure { [weak self] in
				$0.placeholder = "Note"
				$0.text = self?.task.note
				$0.rowHeight = 150
			}.onUpdate { [weak self] (row) in
				if let note = row.text {
					self?.temporallyTask.note = note
				}
		}
		former.append(sectionFormer: SectionFormer(rowFormer: noteRow).set(headerViewFormer: createHeader()))
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@objc func updateTask() {
		if self.task.title.count == 0 {
			let alert = UIAlertController(title: "You need to name your task.", message: "Describe your task briefly.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
		else {
			self.dismiss(animated: true) {
				TaskManager.updateTask {
					self.task.title = self.temporallyTask.title
					self.task.until = self.temporallyTask.until
					self.task.note = self.temporallyTask.note
				}
				NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateTask")))
			}
		}
	}
	
	@objc func cancel() {
		self.dismiss(animated: true, completion: nil)
	}
	
	func switchDueDateRow(_ enabled: Bool, rowFormer: RowFormer, selectRow: Bool) {
		if enabled {
			if self.temporallyTask.until == nil {
				self.temporallyTask.until = Date()
			}
			self.former.insertUpdate(rowFormer: self.untilRow, below: rowFormer)
			if selectRow {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
					self.former.select(indexPath: IndexPath(row: 1, section: 1), animated: true)
				})
			}
		}
		else {
			self.temporallyTask.until = self.task.until
			self.former.removeUpdate(rowFormer: self.untilRow)
		}
	}
}
