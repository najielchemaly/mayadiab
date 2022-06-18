//
//  MainViewController.swift
//  mayadiab
//
//  Created by MR.CHEMALY on 11/27/18.
//  Copyright © 2018 app-loads. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var viewLogo: UIView!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewLayout: UIView!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var collectionViewLayout: UICollectionView!
    @IBOutlet weak var buttonSelectDirectory: UIButton!
    @IBOutlet weak var viewForDirectory: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageViewArrow: UIImageView!
    @IBOutlet weak var labelNoPhotos: UILabel!
    
    var selectedImageAssets: [ImageAsset] = [ImageAsset]()
    var imageAssets: [ImageAsset] = [ImageAsset]()
//    var folders: [ImageFolder] = [ImageFolder]()
    
    let arrowUp = UIImage(named: "up_arrow")
    let arrowDown = UIImage(named: "down_arrow")
    
    var didSaveNewOutfit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initializeViews()
        self.setupDirectoryView()
        self.setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.buttonSelectDirectoryTapped(self.buttonSelectDirectory)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.didSaveNewOutfit {
            if let navigationController = self.presentingViewController as? UINavigationController,
                let homeVC = navigationController.topViewController as? HomeViewController {
                homeVC.setupOutfitAssets()
                homeVC.collectionView.reloadData()
            }
        }
    }
    
    @IBAction func buttonCloseTapped(_ sender: Any) {
        self.dismissVC()
    }
    
    func initializeViews() {
        self.imageViewArrow.image = arrowUp?.withRenderingMode(.alwaysTemplate)
        self.imageViewArrow.tintColor = UIColor.darkGray
    }
    
    func setupDirectoryView() {
//        self.getDirectories(path: "/Outfits")
        
        if let directoryView = DirectoryView.instanceFromNib() as? DirectoryView {
            directoryView.frame = self.viewForDirectory.frame
            directoryView.frame.origin.y = directoryView.frame.height
            directoryView.setupTablevView(folders: Constants.directoryFolders)
            self.viewForDirectory.addSubview(directoryView)
        }
    }
    
    func reloadAssetsFromDirectory(url: String) {
        self.imageAssets = [ImageAsset]()        
        DispatchQueue.global(qos: .background).async {
            let urls = self.listFilesFromDocumentsFolder(mediaPath: url)
            
            for url in urls {
                if !url.isDirectory() {
                    self.imageAssets.append(ImageAsset.init(path: url, selected: false))
                }
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.alpha = 0
                
                self.labelNoPhotos.alpha = self.imageAssets.count > 0 ? 0 : 1
                self.labelNoPhotos.text = "No photos found!"
            }
        }
    }
    
    func setupCollectionView() {
        self.collectionView.register(UINib.init(nibName: CellIds.PhotoCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellIds.PhotoCollectionViewCell)
        self.collectionView.register(UINib.init(nibName: CellIds.PhotoEmptyCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellIds.PhotoEmptyCollectionViewCell)
        
        self.collectionViewLayout.register(UINib.init(nibName: CellIds.OutfitCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellIds.OutfitCollectionViewCell)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.collectionView {
            return 3
        }
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            switch section {
            case 0:
                return 1
            case 1:
                return self.imageAssets.count
            case 2:
                return 1
            default:
                return 0
            }
        }
        
        return self.selectedImageAssets.count > 0 ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            switch indexPath.section {
            case 0:
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.PhotoEmptyCollectionViewCell, for: indexPath) as? PhotoEmptyCollectionViewCell {
                    cell.isUserInteractionEnabled = false
                    cell.backgroundColor = .clear
                    return cell
                }
            case 1:
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.PhotoCollectionViewCell, for: indexPath) as? PhotoCollectionViewCell {
                    let asset = self.imageAssets[indexPath.row]
                    let selected = self.selectedImageAssets.contains(where: { $0.path == asset.path })
                    cell.setSelected(isSelected: selected)
                    
//                    if let selected = asset.selected {
//                        cell.setSelected(isSelected: selected)
//                    }
                    
                    if let image = UIImage.init(contentsOfFile: asset.path) {
                        asset.image = image
                        cell.imageViewPhoto.image = image
                    }
                    
                    cell.imageViewPhoto.backgroundColor = .white
                    
                    cell.resetConstraints()
                    
                    return cell
                }
            case 2:
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.PhotoEmptyCollectionViewCell, for: indexPath) as? PhotoEmptyCollectionViewCell {
                    cell.isUserInteractionEnabled = false
                    cell.backgroundColor = .clear
                    return cell
                }
            default:
                return UICollectionViewCell()
            }
        } else {
            if let cell = collectionViewLayout.dequeueReusableCell(withReuseIdentifier: CellIds.OutfitCollectionViewCell, for: indexPath) as? OutfitCollectionViewCell {
                cell.initializeViews(assets: self.selectedImageAssets)
                
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    let itemSpacing: CGFloat = 5
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            switch indexPath.section {
            case 0:
                return CGSize(width: collectionView.frame.width, height: self.viewTop.frame.height)
            case 1:
                let itemWidth = (collectionView.bounds.width/5)-(itemSpacing/5)
                return CGSize(width: itemWidth, height: itemWidth)
            case 2:
                return CGSize(width: collectionView.frame.width, height: 70)
            default:
                return CGSize.zero
            }
        } else {
            let itemWidth = collectionView.bounds.height-itemSpacing
            return CGSize(width: itemWidth, height: itemWidth)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.collectionViewLayout {
            let itemWidth = collectionView.bounds.height-itemSpacing
            
            let leftInset = (collectionView.bounds.width - CGFloat(itemWidth)) / 2
            let rightInset = leftInset
            
            return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
        }
        
        return UIEdgeInsets.zero
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
            if !selected && self.selectedImageAssets.count == 8 {
                self.showAlert(message: "You cannot select more than 8 photos", style: .alert)
                return
            }
            
            cell.setSelected(isSelected: !selected)
            asset.selected = !selected
            self.imageAssets[indexPath.row] = asset
            
            if asset.selected == true {
                self.selectedImageAssets.append(asset)
            } else if let indexToRemove = self.selectedImageAssets.index(where: { $0.path == asset.path }) {
                self.selectedImageAssets.remove(at: indexToRemove)
            }
            
            if self.selectedImageAssets.count == 0 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.viewLogo.alpha = 1
                    self.viewLayout.alpha = 0
                })
            } else if self.selectedImageAssets.count == 1 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.viewLogo.alpha = 0
                    self.viewLayout.alpha = 1
                })
            }
            
            self.collectionViewLayout.reloadData()
        }
    }

    @IBAction func buttonSelectDirectoryTapped(_ sender: Any) {
        self.updateButtonSelectDirectories()
        self.viewForDirectory.alpha == 0 ? self.showDirectoryView() : self.hideDirectoryView()
    }
    
    func showDirectoryView() {
        self.viewForDirectory.alpha = 1
        if let directoryView = self.viewForDirectory.subviews.last as? DirectoryView {
            UIView.animate(withDuration: 0.3, animations: {
                directoryView.frame.origin.y = 0
            })
        }
    }
    
    func hideDirectoryView() {
        if let directoryView = self.viewForDirectory.subviews.last as? DirectoryView {
            UIView.animate(withDuration: 0.3, animations: {
                directoryView.frame.origin.y = directoryView.frame.height
            }, completion: { success in
                self.viewForDirectory.alpha = 0
            })
        }
    }
    
    func updateButtonSelectDirectories() {
        self.buttonSelectDirectory.setTitle(self.viewForDirectory.alpha == 0 ? "CLOSE DIRECTORIES" : "OPEN DIRECTORIES", for: .normal)
        self.imageViewArrow.image = self.viewForDirectory.alpha == 0 ? arrowDown?.withRenderingMode(.alwaysTemplate) : arrowUp?.withRenderingMode(.alwaysTemplate)
        self.imageViewArrow.tintColor = UIColor.darkGray
    }
    
    @IBAction func buttonCloseEditingTapped(_ sender: Any) {
        self.imageAssets.forEach { $0.selected = false }
        self.collectionView.reloadData()
        
        self.selectedImageAssets.removeAll()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.viewLogo.alpha = 1
            self.viewLayout.alpha = 0
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
