//
//  TaskCell.swift
//  dyt
//
//  Created by Akira Matsuda on 2018/02/03.
//  Copyright © 2018 Akira Matsuda. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {
	@IBOutlet weak var taskLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
