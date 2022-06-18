//
//  PhotoCollectionViewCell.swift
//  mayadiab
//
//  Created by MR.CHEMALY on 11/28/18.
//  Copyright © 2018 app-loads. All rights reserved.
//

import UIKit
import Photos

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet weak var viewCheck: UIView!
    @IBOutlet weak var imageCheck: UIImageView!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

extension PhotoCollectionViewCell {
    func initializeViews() {
        self.backgroundColor = .clear
    }
    
    func configure(imageAsset: ImageAsset, photos: PHFetchResult<PHAsset>?, indexPath: IndexPath) {
        self.backgroundColor = .clear
        //        self.imageViewPhoto.layer.cornerRadius = Dimensions.cornerRadiusNormal
        
        guard let asset = photos?.object(at: indexPath.row) else {
            return
        }
        
        self.imageViewPhoto.fetchImage(imageAsset: imageAsset, asset: asset, contentMode: .aspectFill, targetSize: self.imageViewPhoto.frame.size)
    }
    
    func setSelected(isSelected: Bool = false) {
        self.viewCheck.isHidden = !isSelected
        self.viewCheck.layer.borderColor = Colors.blue.cgColor
        self.viewCheck.layer.borderWidth = 3
    }
    
    func resetConstraints() {
        self.topConstraint.constant = 0
        self.bottomConstraint.constant = 0
        self.leadingConstraint.constant = 0
        self.trailingConstraint.constant = 0
    }
}
