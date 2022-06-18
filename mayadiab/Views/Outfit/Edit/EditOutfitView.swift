//
//  EditOutfitView.swift
//  mayadiab
//
//  Created by MR.CHEMALY on 12/23/18.
//  Copyright © 2018 app-loads. All rights reserved.
//

import UIKit
import Photos
import FBSDKCoreKit
import FBSDKShareKit

class EditOutfitView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var buttonReplace: UIButton!
    @IBOutlet weak var viewReplace: UIView!
    @IBOutlet weak var stackViewShare: UIStackView!
    @IBOutlet weak var buttonInstagram: UIButton!
    @IBOutlet weak var buttonFacebook: UIButton!
    @IBOutlet weak var buttonMore: UIButton!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buttonOpenDirectoryView: UIButton!
    
    var outfitImage: UIImage!
    var images: [UIImageView]!
    var outfitView: OutfitView!
    var selectedImageIndex = 0
    
    var selectedImageAssets: [ImageAsset] = [ImageAsset]()
    var imageAssets: [ImageAsset] = [ImageAsset]()
    
    let arrowUp = UIImage(named: "up_arrow_small")
    let arrowDown = UIImage(named: "down_arrow_small")
    
    func initializeViews() {
        self.buttonReplace.layer.cornerRadius = Dimensions.cornerRadiusNormal
        self.buttonInstagram.layer.cornerRadius = Dimensions.cornerRadiusNormal
        self.buttonFacebook.layer.cornerRadius = Dimensions.cornerRadiusNormal
        self.buttonMore.layer.cornerRadius = Dimensions.cornerRadiusNormal
        
        self.buttonReplace.isEnabled(enable: false)
        
        self.setupImages()
        self.setupGestures()
        self.setupDirectoryView()
        self.setupCollectionView()
    }
    
    private func setupImages() {
        if let outfitView = self.outfitView {//.subviews.last as? OutfitView {
            self.images = [UIImageView]()
            self.addImage(imageView: outfitView.imageOne)
            self.addImage(imageView: outfitView.imageTwo)
            self.addImage(imageView: outfitView.imageThree)
            self.addImage(imageView: outfitView.imageFour)
            self.addImage(imageView: outfitView.imageFive)
            self.addImage(imageView: outfitView.imageSix)
            self.addImage(imageView: outfitView.imageSeven)
            self.addImage(imageView: outfitView.imageEight)
        }
    }
    
    private func setupGestures() {
        for imageView in self.images {
            self.addGesture(image: imageView)
        }
    }
    
    private func setupDirectoryView() {
        if let directoryView = DirectoryView.instanceFromNib() as? DirectoryView {
            directoryView.alpha = 0
            directoryView.parentView = self
            directoryView.frame = self.viewBottom.frame
            directoryView.frame.origin.y = directoryView.frame.height
            directoryView.setupTablevView(folders: Constants.directoryFolders)
            self.viewBottom.addSubview(directoryView)
        }
    }
    
    @objc private func imageTapped(sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView {
            self.deselectImages()
            UIView.animate(withDuration: 0.3, animations: {
                imageView.setSelected(isSelected: !imageView.isSelected())
            })
            
            self.selectedImageIndex = imageView.tag
            self.buttonReplace.isEnabled(enable: true)
        }
    }
    
    func showDirectoryView() {
        if let directoryView = self.viewBottom.subviews.last as? DirectoryView {
            directoryView.alpha = 1
            UIView.animate(withDuration: 0.3, animations: {
                directoryView.frame.origin.y = 0
                
                self.buttonSave.setTitle("DONE", for: .normal)
                self.buttonSave.tag = 1
                self.buttonClose.alpha = 0
            }, completion: { success in
                self.collectionView.alpha = 1
            })
        }
    }
    
    func hideDirectoryView() {
        if let directoryView = self.viewBottom.subviews.last as? DirectoryView {
            UIView.animate(withDuration: 0.3, animations: {
                directoryView.frame.origin.y = directoryView.frame.height
                
                self.buttonSave.setTitle("SAVE", for: .normal)
                self.buttonSave.tag = 0
                self.buttonClose.alpha = 0
            }, completion: { success in
                directoryView.alpha = 0
            })
        }
    }
    
    func reloadAssetsFromDirectory(url: String) {
        self.imageAssets = [ImageAsset]()
        DispatchQueue.global(qos: .background).async {
            if let baseVC = currentVC as? BaseViewController {
                let urls = baseVC.listFilesFromDocumentsFolder(mediaPath: url)
                
                for url in urls {
                    if !url.isDirectory() {
                        self.imageAssets.append(ImageAsset.init(path: url, selected: false))
                    }
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func setupCollectionView() {
        self.collectionView.register(UINib.init(nibName: CellIds.PhotoCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellIds.PhotoCollectionViewCell)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.PhotoCollectionViewCell, for: indexPath) as? PhotoCollectionViewCell {
            let asset = self.imageAssets[indexPath.row]
            let selected = self.selectedImageAssets.contains(where: { $0.path == asset.path })
            cell.setSelected(isSelected: selected)
            
            if let image = asset.image {
                cell.imageViewPhoto.image = image
            } else if let image = UIImage.init(contentsOfFile: asset.path) {
                asset.image = image
                cell.imageViewPhoto.image = image
            }
            
            cell.imageViewPhoto.backgroundColor = .white
            
            cell.resetConstraints()
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    let itemSpacing: CGFloat = 5
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (collectionView.bounds.width/5)-(itemSpacing/5)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.collectionView {
            return section == 1 ? itemSpacing/5 : 0
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.collectionView {
            return section == 1 ? itemSpacing/2 : 0
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
            let asset = self.imageAssets[indexPath.row]
            let selected = self.selectedImageAssets.contains(where: { $0.path == asset.path })
            if selected {
                return
            }
            
            cell.setSelected(isSelected: !selected)
            asset.selected = !selected
            
            if asset.selected == true {
                self.selectedImageAssets[self.selectedImageIndex-1] = asset
            }
            
            if let outfitView = self.outfitView {
                switch self.selectedImageIndex {
                case 1:
                    outfitView.imageOne.image = asset.image
                    break
                case 2:
                    outfitView.imageTwo.image = asset.image
                    break
                case 3:
                    outfitView.imageThree.image = asset.image
                    break
                case 4:
                    outfitView.imageFour.image = asset.image
                    break
                case 5:
                    outfitView.imageFive.image = asset.image
                    break
                case 6:
                    outfitView.imageSix.image = asset.image
                    break
                case 7:
                    outfitView.imageSeven.image = asset.image
                    break
                case 8:
                    outfitView.imageEight.image = asset.image
                    break
                default:
                    break
                }
            }
            
            self.collectionView.reloadData()
        }
    }
    
    private func deselectImages() {
        for imageView in images {
            imageView.setSelected(isSelected: false)
        }
    }
    
    @IBAction func buttonOpenTapped(_ sender: Any) {
        self.updateButtonOpenDirectoryView()
        if let directoryView = self.viewBottom.subviews.last as? DirectoryView {
            directoryView.alpha == 0 ? self.showDirectoryView() : self.hideDirectoryView()
        }
    }
    
    private func updateButtonOpenDirectoryView() {
        if let directoryView = self.viewBottom.subviews.last as? DirectoryView {
            self.buttonOpenDirectoryView.setTitle(directoryView.alpha == 0 ? "CLOSE" : "OPEN", for: .normal)
            self.buttonOpenDirectoryView.setImage(directoryView.alpha == 0 ? arrowDown : arrowUp, for: .normal)
        }
    }
    
    @IBAction func buttonCloseTapped(_ sender: Any) {
        if let outfitView = self.outfitView {
            outfitView.viewOverlay?.isUserInteractionEnabled = true
        }
        if let mainVC = currentVC as? MainViewController {
            mainVC.collectionViewLayout.reloadData()
        }
        
        self.hide(remove: true)
    }
    
    @IBAction func buttonSaveTapped(_ sender: Any) {
        if self.buttonSave.tag == 0 {
            self.deselectImages()
            if (FileManager.default.saveAssetToFolder(path: "Outfits", image: self.getOutfitImage(), isOutfit: true) != nil) {
//                UIImageWriteToSavedPhotosAlbum(self.getOutfitImage(), nil, nil, nil)
                
                if let mainVC = currentVC as? MainViewController {
                    self.hide(remove: true)
                    mainVC.didSaveNewOutfit = true
//                    mainVC.showAlert(message: "Outfit saved successfully", style: .alert)

                    if let editOutfitView = self.superview?.subviews.last as? EditOutfitView {
                        editOutfitView.hide(remove: true)
                    }
                    
                    if let mainVC = currentVC as? MainViewController {
                        mainVC.dismissVC()
                    }
                    
//                    UIView.animate(withDuration: 0.2, animations: {
//                        self.viewReplace.alpha = 0
//                    }, completion: { success in
//                        UIView.animate(withDuration: 0.2, animations: {
//                            self.stackViewShare.alpha = 1
//                        })
//                    })
                }
            }
        } else {
            self.collectionView.alpha = 0
            self.hideDirectoryView()
        }
    }
    
    @IBAction func buttonReplaceTapped(_ sender: Any) {
        self.showDirectoryView()
    }
    
    @IBAction func buttonInstagramTapped(_ sender: Any) {
        if let instagramURL = URL(string: "instagram://app") {
            if (UIApplication.shared.canOpenURL(instagramURL)) {
                let image = self.getOutfitImage()
                do {
                    try PHPhotoLibrary.shared().performChangesAndWait {
                        let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                        
                        let assetID = request.placeholderForCreatedAsset?.localIdentifier ?? ""
                        let shareURL = "instagram://library?LocalIdentifier=" + assetID
                        
                        if let urlForRedirect = URL(string: shareURL) {
                            DispatchQueue.main.async {
                                UIApplication.shared.open(urlForRedirect)
                            }
                        }
                    }
                } catch let error as NSError {
                    print(error)
                }
            } else {
                print(" Instagram isn't installed ")
                
                if let url = URL(string: "https://itunes.apple.com/us/app/instagram/id389801252?mt=8") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    @IBAction func buttonFacebookTapped(_ sender: Any) {
        let image = self.getOutfitImage()
        let sharePhoto = SharePhoto(image: image, userGenerated: true)
        let content = SharePhotoContent()
        content.photos = [sharePhoto]
        let shareDialog = ShareDialog()
        if shareDialog.canShow {
            shareDialog.shareContent = content
            
            DispatchQueue.main.async {
                let result = shareDialog.show()
                if !result {
                    if let url = URL(string: "https://itunes.apple.com/cy/app/facebook/id284882215?mt=8") {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        
    }
    
    @IBAction func buttonMoreTapped(_ sender: Any) {
        if let baseVC = currentVC as? BaseViewController {
            let linkToShare = [self.getOutfitImage()]
            
            let activityController = UIActivityViewController(activityItems: linkToShare, applicationActivities: nil)
            if activityController.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
                activityController.popoverPresentationController?.sourceView = self.stackViewShare
            }
            
            DispatchQueue.main.async {
                baseVC.present(activityController, animated: true, completion: nil)
            }
        }
    }
    
    private func getOutfitImage() -> UIImage {
        if let image = outfitImage {
            return image
        }
        
        return self.outfitView.getImage()
    }
    
    private func addGesture(image: UIImageView) {
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(sender:)))
        image.addGestureRecognizer(imageTap)
    }
    
    private func addImage(imageView: UIImageView?) {
        if let image = imageView {
            self.images.append(image)
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
