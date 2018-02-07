//
//  NewTaskViewController.swift
//  dyt
//
//  Created by Akira Matsuda on 2018/02/04.
//  Copyright © 2018 Akira Matsuda. All rights reserved.
//

import UIKit
import Former

class NewTaskViewController: FormViewController {
	var task = Task()
	
	lazy var untilRow: SelectorDatePickerRowFormer = { () -> SelectorDatePickerRowFormer<FormSelectorDatePickerCell> in
		let untilRow = SelectorDatePickerRowFormer<FormSelectorDatePickerCell> {
			$0.titleLabel.text = "Until"
			}.displayTextFromDate(String.mediumDateShortTime)
			.onDateChanged { [weak self] (date) in
				self?.task.until = date
		}
		untilRow.selectorView.datePickerMode = .dateAndTime
		if let date = self.task.until {
			untilRow.date = date
			untilRow.selectorView.date = date
		}
		return untilRow
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.title = "New Task"
		let addButton = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(self.addTask))
		let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancel))
		self.navigationItem.rightBarButtonItem = addButton
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
			}.configure {
				$0.placeholder = "Title"
			}.onTextChanged { [weak self] (text) in
				self?.task.title = text
		}
		self.former.append(sectionFormer: SectionFormer(rowFormer: titleRow).set(headerViewFormer: createHeader()))
		
		let moreRow = SwitchRowFormer<FormSwitchCell>() {
			$0.titleLabel.text = "Add due date"
			}.configure {
				$0.switched = false
				$0.switchWhenSelected = true
			}
		moreRow.onSwitchChanged { [weak self] in
			self?.switchDueDateRow($0, rowFormer: moreRow, selectRow: true)
		}
		self.former.append(sectionFormer: SectionFormer(rowFormer: moreRow).set(headerViewFormer: createHeader()))
		
		let noteRow = TextViewRowFormer<FormTextViewCell>() {
			$0.textView.textColor = .formerSubColor()
			$0.textView.font = .systemFont(ofSize: 15)
			}.configure {
				$0.placeholder = "Note"
				$0.rowHeight = 150
			}.onUpdate { [weak self] (row) in
				if let note = row.text {
					self?.task.note = note
				}
		}
		self.former.append(sectionFormer: SectionFormer(rowFormer: noteRow).set(headerViewFormer: createHeader()))
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.former.select(indexPath: IndexPath(row: 0, section: 0), animated: true)
		}
	}
	
	@objc func addTask() {
		if self.task.title.count == 0 {
			let alert = UIAlertController(title: "You need to name your task.", message: "Describe your task briefly.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
		else {
			self.dismiss(animated: true) { [weak self] in
				if let t = self?.task {
					TaskManager.add(t)
				}
			}
		}
	}
	
	@objc func cancel() {
		self.dismiss(animated: true, completion: nil)
	}
	
	func switchDueDateRow(_ enabled: Bool, rowFormer: RowFormer, selectRow: Bool) {
		if enabled {
			self.task.until = Date()
			self.former.insertUpdate(rowFormer: self.untilRow, below: rowFormer)
			if selectRow {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
					self.former.select(indexPath: IndexPath(row: 1, section: 1), animated: true)
				})
			}
		}
		else {
			self.task.until = nil
			self.former.removeUpdate(rowFormer: self.untilRow)
		}
	}
}
