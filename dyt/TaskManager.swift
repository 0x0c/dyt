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
	enum UpdateType : String {
		case add = "add"
		case update = "update"
		case complete = "complete"
		case delete = "delete"
	}
	
	static func add(_ task: Task) {
		let realm = try! Realm()
		try! realm.write {
			realm.add(task)
			NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateTask"), object: nil, userInfo: ["updateType" : UpdateType.add]))
		}
	}
	
	static func update(_ handler: @escaping (() -> Void), silentUpdate: Bool = false) {
		let realm = try! Realm()
		try! realm.write {
			handler()
			if silentUpdate == false {
				NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateTask"), object: nil, userInfo: ["updateType" : UpdateType.update]))
			}
		}
	}
	static func complete(_ task: Task) {
		TaskManager.update({
			task.state = .done
			NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateTask"), object: nil, userInfo: ["updateType" : UpdateType.complete]))
		}, silentUpdate: true)
	}
	
	static func delete(_ task: Task) {
		let realm = try! Realm()
		try! realm.write {
			realm.delete(task)
			NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateTask"), object: nil, userInfo: ["updateType" : UpdateType.delete]))
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
