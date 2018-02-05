//
//  TaskManager.swift
//  dyt
//
//  Created by Akira Matsuda on 2018/02/04.
//  Copyright © 2018 Akira Matsuda. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers
class TaskManager: NSObject {
	
	static func addTask(_ task: Task) {
		let realm = try! Realm()
		try! realm.write {
			realm.add(task)
		}
	}
	
	static func updateTask(_ handler: @escaping (() -> Void)) {
		let realm = try! Realm()
		try! realm.write {
			handler()
		}
	}
	
	static func deleteTask(_ task: Task) {
		let realm = try! Realm()
		try! realm.write {
			realm.delete(task)
		}
	}
	
	static func tasks() -> Results<Task> {
		let realm = try! Realm()
		return realm.objects(Task.self)
	}
}

extension Results {
	func completed() -> Results<Task> {
		return self.filter("_state == 'done'") as! Results<Task>
	}
	
	func rejected() -> Results<Task> {
		return self.filter("_state == 'rejected'") as! Results<Task>
	}
	
	func inProgress() -> Results<Task> {
		return self.filter("_state == 'incompleted'") as! Results<Task>
	}
	
	func outdated() -> Results<Task> {
		return self.filter(NSPredicate("until", fromDate: nil, toDate: NSDate())) as! Results<Task>
	}
	
	func future() -> Results<Task> {
		return self.filter(NSPredicate("until", fromDate: NSDate(), toDate: nil)) as! Results<Task>
	}
}

extension NSPredicate {
	public convenience init(_ property: String, fromDate: NSDate?, toDate: NSDate?) {
		var format = "", args = [AnyObject]()
		if let from = fromDate {
			format += "\(property) >= %@"
			args.append(from)
		}
		if let to = toDate {
			if !format.isEmpty {
				format += " AND "
			}
			format += "\(property) <= %@"
			args.append(to)
		}
		if !args.isEmpty {
			self.init(format: format, argumentArray: args)
		} else {
			self.init(value: true)
		}
	}
}
