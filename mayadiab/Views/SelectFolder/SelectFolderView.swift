//
//  SelectFolderView.swift
//  mayadiab
//
//  Created by MR.CHEMALY on 12/29/18.
//  Copyright © 2018 app-loads. All rights reserved.
//

import UIKit

class SelectFolderView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var folder: ImageFolder = ImageFolder()
    private var folderToMove: ImageFolder = ImageFolder()
    private var selectedAssets: [ImageAsset] = [ImageAsset]()
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func setupCollectionView(folder: ImageFolder, selectedAssets: [ImageAsset]) {
        if let baseVC = currentVC as? BaseViewController {
            baseVC.getDirectories(path: "/Media")
        }
        
        self.folder = folder
        self.selectedAssets = selectedAssets
        
        self.collectionView.register(UINib.init(nibName: CellIds.FolderCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellIds.FolderCollectionViewCell)
    }
    
    func setupCollectionView(folder: ImageFolder, folderToMove: ImageFolder) {
        if let baseVC = currentVC as? BaseViewController {
            baseVC.getDirectories(path: "/Media")
        }
        
        self.folder = folder
        self.folderToMove = folderToMove
        
        self.collectionView.register(UINib.init(nibName: CellIds.FolderCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellIds.FolderCollectionViewCell)
    }
    
    // MARK UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.directoryFolders.count//self.folder.subfolders?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.FolderCollectionViewCell, for: indexPath) as? FolderCollectionViewCell {
            let subfolder = Constants.directoryFolders[indexPath.row] //self.folder.subfolders?[indexPath.row]
            cell.labelName.text = subfolder.name
            
            if let thumb = subfolder.thumb {
                let image = UIImage(named: thumb)
                cell.imageViewIcon.image = image == nil ? UIImage(named: "folder") : image
            }
            
            if let name = subfolder.name {
                cell.labelName.text = name
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    // MARK UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let folderDetailVC = currentVC as? FolderDetailViewController {
            let selectedFolder = Constants.directoryFolders[indexPath.row]
            let fileManager = FileManager.default
            
            if self.selectedAssets.count > 0 {
                for selectedAsset in self.selectedAssets {
                    guard let filePathToMove = selectedAsset.path else {
                        break
                    }
                    guard let filePathDestination = selectedFolder.path else {
                        break
                    }
                    guard let fileName = selectedAsset.name else {
                        break
                    }
                    do {
                        try fileManager.moveItem(atPath: filePathToMove, toPath: "\(filePathDestination)/\(fileName)")
                        
                        guard let indexToDelete = self.folder.images.firstIndex(where: { $0.path == selectedAsset.path }) else {
                            return
                        }
                        self.folder.images.remove(at: indexToDelete)
                        
                        if let folderToUpdate = self.folder.subfolders.first(where: { $0.path == selectedFolder.path }) {
                            folderToUpdate.images?.append(selectedAsset)
                        }
                        
                        DispatchQueue.main.async {
                            folderDetailVC.collectionView.reloadData()
                            folderDetailVC.buttonSelectTapped()
                            folderDetailVC.hideView()
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                        DispatchQueue.main.async {
                            folderDetailVC.showAlert(message: "\(fileName) already exists in the destination folder", style: .alert)
                        }
                        break
                    }
                }
            } else {
                guard let folderPathToMove = folderToMove.path else {
                    return
                }
                guard let folderPathDestination = selectedFolder.path else {
                    return
                }
                guard let fileName = folderToMove.name else {
                    return
                }
                do {
                    try fileManager.moveItem(atPath: folderPathToMove, toPath: "\(folderPathDestination)/\(fileName)")
                    
                    guard let indexToDelete = self.folder.subfolders.firstIndex(where: { $0.path == folderToMove.path }) else {
                        return
                    }
                    self.folder.subfolders.remove(at: indexToDelete)
                    
                    if let folderToUpdate = self.folder.subfolders.first(where: { $0.path == folderToMove.path }) {
//                        folderToUpdate.append(folderToMove)
                    }
                    
                    DispatchQueue.main.async {
                        folderDetailVC.collectionView.reloadData()
                        folderDetailVC.buttonSelectTapped()
                        folderDetailVC.hideView()
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        folderDetailVC.showAlert(message: "\(fileName) already exists in the destination folder", style: .alert)
                    }
                    return
                }
            }
        }
    }
    
    // MARK UICollectionViewDelegateFlowLayout
    
    let itemSpacing: CGFloat = 5
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (collectionView.bounds.width/3)-(itemSpacing/3)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing/2
    }
    
    @IBAction func buttonCancelTapped(_ sender: Any) {
        self.hide(remove: true)
    }
    
}
