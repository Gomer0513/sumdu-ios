//
//  ShareButton.swift
//  SumDU
//
//  Created by Yura Voevodin on 13.07.16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import UIKit

class ShareButton: UIButton {
    
    // MARK: - Constants
    
    static let buttonSize = CGSize(width: 44.0, height: 44.0)
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setImage(UIImage(named: "share_normal"), forState: .Normal)
        setImage(UIImage(named: "share_pressed"), forState: .Selected)
        contentMode = .ScaleAspectFill
        clipsToBounds = true
    }
}