//
//  ReportCollectionViewCell.swift
//  Chivia
//
//  Created by Agustín Rodríguez on 10/29/17.
//  Copyright © 2017 Agustín Rodríguez. All rights reserved.
//

import LGButton
import UIKit

class ReportCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet var view: UIView!
    
    @IBOutlet var button: LGButton!
    @IBOutlet var label: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed("ReportCollectionViewCell", owner: self, options: nil)
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
}
