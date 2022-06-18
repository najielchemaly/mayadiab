//
//  AddFolderView.swift
//  mayadiab
//
//  Created by MR.CHEMALY on 12/17/18.
//  Copyright © 2018 app-loads. All rights reserved.
//

import UIKit

class AddFolderView: UIView {

    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var viewFolderName: UIView!
    @IBOutlet weak var textFieldFolderName: UITextField!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func initializeViews() {
        self.viewPopup.layer.cornerRadius = Dimensions.cornerRadiusNormal
        self.viewFolderName.layer.cornerRadius = Dimensions.cornerRadiusNormal
        self.buttonSave.layer.cornerRadius = self.buttonSave.frame.height/2
    }
    
    @IBAction func buttonCancelTapped(_ sender: Any) {
        self.hide(remove: true)
    }
}
