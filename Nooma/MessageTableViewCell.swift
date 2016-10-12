//
//  MessageTableViewCell.swift
//  Nooma
//
//  Created by Jae Hoon Lee on 10/11/16.
//  Copyright © 2016 Nooma. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    static let REUSE_ID = "MessageTableViewCell"
    
    let nameLabel : UILabel = UILabel()
    let bodyLabel: UILabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.numberOfLines = 0
        
        self.addSubview(nameLabel)
        self.addSubview(bodyLabel)
        
        let views = ["nameLabel": nameLabel, "bodyLabel": bodyLabel]
        
        //Horizontal constraints
        let nameLabelHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[nameLabel]-10-|", options: [], metrics: nil, views: views)
        
        let bodyLabelHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[bodyLabel]-10-|", options: [], metrics: nil, views: views)
        self.addConstraints(nameLabelHorizontalConstraints)
        self.addConstraints(bodyLabelHorizontalConstraints)
        
        //Vertical constraints
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[nameLabel]-5-[bodyLabel]-10-|", options: [], metrics: nil, views: views)
        self.addConstraints(verticalConstraints)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
