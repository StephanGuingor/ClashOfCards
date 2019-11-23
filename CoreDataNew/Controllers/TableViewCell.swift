//
//  TableViewCell.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/12/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    
    @IBOutlet weak var imView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
