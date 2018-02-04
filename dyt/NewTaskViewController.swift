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
	let task = Task()
	
	private lazy var untilRow: SelectorDatePickerRowFormer = { () -> SelectorDatePickerRowFormer<FormSelectorDatePickerCell> in
		let untilRow = SelectorDatePickerRowFormer<FormSelectorDatePickerCell> {
			$0.titleLabel.text = "Until"
			}.displayTextFromDate(String.mediumDateNoTime)
			.onDateChanged { [weak self] (date) in
				self?.task.until = date
		}
		untilRow.selectorView.datePickerMode = .date
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
			$0.textField.font = .systemFont(ofSize: 15)
			}.configure {
				$0.placeholder = "Title"
			}.onTextChanged { [weak self] (text) in
				self?.task.title = text
		}
		former.append(sectionFormer: SectionFormer(rowFormer: titleRow).set(headerViewFormer: createHeader()))
		
		let moreRow = SwitchRowFormer<FormSwitchCell>() {
			$0.titleLabel.text = "Add due date"
			}.configure {
				$0.switched = false
				$0.switchWhenSelected = true
			}
		moreRow.onSwitchChanged { [weak self] in
			self?.switchDueDateRow($0, rowFormer: moreRow)
		}
		former.append(sectionFormer: SectionFormer(rowFormer: moreRow).set(headerViewFormer: createHeader()))
		
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
		former.append(sectionFormer: SectionFormer(rowFormer: noteRow).set(headerViewFormer: createHeader()))
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.former.select(indexPath: IndexPath(row: 0, section: 0), animated: true)
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@objc func addTask() {
		if self.task.title.count == 0 {
			let alert = UIAlertController(title: "You need to name your task.", message: "Describe your task briefly.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
		else {
			self.dismiss(animated: true) {
				TaskManager.addTask(self.task)
				NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateTask")))
			}
		}
	}
	
	@objc func cancel() {
		self.dismiss(animated: true, completion: nil)
	}
	
	func switchDueDateRow(_ enabled: Bool, rowFormer: RowFormer) {
		if enabled {
			self.task.until = Date()
			self.former.insertUpdate(rowFormer: self.untilRow, below: rowFormer)
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
				self.former.select(indexPath: IndexPath(row: 1, section: 1), animated: true)
			})
		}
		else {
			self.task.until = nil
			self.former.removeUpdate(rowFormer: self.untilRow)
		}
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
