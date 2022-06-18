//
//  EightOutfitCollectionViewCell.swift
//  mayadiab
//
//  Created by MR.CHEMALY on 12/23/18.
//  Copyright © 2018 app-loads. All rights reserved.
//

import UIKit

class OutfitCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    
    var outfitView: OutfitView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initializeViews(assets: [ImageAsset]) {
        self.setupOutfitView()
        self.setupImages(assets: assets)
        
        switch assets.count {
        case 1:
            remove(view: self.outfitView.stackTwo)
            remove(view: self.outfitView.imageTwo)
            remove(view: self.outfitView.imageThree)
            remove(view: self.outfitView.imageFour)
            break
        case 2:
            remove(view: self.outfitView.stackTwo)
            remove(view: self.outfitView.imageThree)
            remove(view: self.outfitView.imageFour)
            break
        case 3:
            remove(view: self.outfitView.stackTwo)
            remove(view: self.outfitView.imageFour)
            break
        case 4:
            remove(view: self.outfitView.stackTwo)
            break
        case 5:
            remove(view: self.outfitView.imageSix)
            remove(view: self.outfitView.imageSeven)
            remove(view: self.outfitView.imageEight)
            break
        case 6:
            remove(view: self.outfitView.imageSeven)
            remove(view: self.outfitView.imageEight)
            break
        case 7:
            remove(view: self.outfitView.imageEight)
            break
        default:
            break
        }
    }
    
    private func setupOutfitView() {
        let outfitView: OutfitView = UIView.fromNib()
        self.outfitView = outfitView
        let frame = self.mainView.frame
        self.outfitView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        self.add(view: self.outfitView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(outfitViewTapped))
        self.outfitView.viewOverlay.addGestureRecognizer(tap)
    }
    
    @objc private func outfitViewTapped() {
        if let mainVC = currentVC as? MainViewController, let editOutfitView = mainVC.showView(name: Views.EditOutfitView) as? EditOutfitView {
            editOutfitView.outfitView = self.outfitView
            let frame = editOutfitView.mainView.frame
            editOutfitView.outfitView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            editOutfitView.outfitView.viewOverlay?.isUserInteractionEnabled = false
            editOutfitView.selectedImageAssets = mainVC.selectedImageAssets
            editOutfitView.mainView.addSubview(editOutfitView.outfitView)
            editOutfitView.initializeViews()
        }
    }
    
    private func setupImages(assets: [ImageAsset]) {
        var index = 0
        for _ in assets {
            switch index {
            case 0:
                setImage(imageView: self.outfitView.imageOne, image: assets[index].image)
                break
            case 1:
                setImage(imageView: self.outfitView.imageTwo, image: assets[index].image)
                break
            case 2:
                setImage(imageView: self.outfitView.imageThree, image: assets[index].image)
                break
            case 3:
                setImage(imageView: self.outfitView.imageFour, image: assets[index].image)
                break
            case 4:
                setImage(imageView: self.outfitView.imageFive, image: assets[index].image)
                break
            case 5:
                setImage(imageView: self.outfitView.imageSix, image: assets[index].image)
                break
            case 6:
                setImage(imageView: self.outfitView.imageSeven, image: assets[index].image)
                break
            case 7:
                setImage(imageView: self.outfitView.imageEight, image: assets[index].image)
                break
            default:
                break
            }
            
            index += 1
        }
    }
    
    func remove(view: UIView?) {
        if view != nil {
            view?.removeFromSuperview()
        }
    }
    
    func setImage(imageView: UIImageView?, image: UIImage) {
        if imageView != nil {
            imageView?.image = image
        }
    }

}

extension OutfitCollectionViewCell {
    func add(view: UIView) {
        if let outiftView = self.subviews.last as? OutfitView {
            outiftView.removeFromSuperview()
        }
        
        self.mainView.addSubview(view)
    }
}
