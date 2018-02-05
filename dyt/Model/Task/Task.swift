//
//  Task.swift
//  dyt
//
//  Created by Akira Matsuda on 2018/02/04.
//  Copyright © 2018 Akira Matsuda. All rights reserved.
//

import UIKit
import RealmSwift

enum State : String {
	case incompleted = "incompleted"
	case done = "done"
	case rejected = "rejected"
}

@objcMembers
class Task: Object {
	dynamic var identifier: String {
		get {
			return NSUUID.init().uuidString
		}
	}
	
	dynamic var title = ""
	dynamic var created = Date()
	dynamic var until: Date? = nil
	dynamic var note = ""
	@objc dynamic private var _state = State.incompleted.rawValue
	var state: State {
		get {
			return State(rawValue: self._state)!
		}
		set(s) {
			self._state = s.rawValue
		}
	}
}
