//
//  weatherCell.swift
//  weatherApp
//
//  Created by Shalev Lazarof on 01/07/2019.
//  Copyright © 2019 Shalev Lazarof. All rights reserved.
//

import UIKit

class weatherCell: UITableViewCell {

    @IBOutlet weak var DayLabel: UILabel!
    @IBOutlet weak var TempLabel: UILabel!
    @IBOutlet weak var WeatherIconImageView: UIImageView!
    @IBOutlet weak var DescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
