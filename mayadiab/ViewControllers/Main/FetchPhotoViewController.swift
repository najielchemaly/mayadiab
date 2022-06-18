//
//  FetchPhotoViewController.swift
//  mayadiab
//
//  Created by MR.CHEMALY on 12/24/18.
//  Copyright © 2018 app-loads. All rights reserved.
//

import UIKit
import Photos

class FetchPhotoViewController: BaseViewController {
    
    @IBOutlet weak var buttonCancel: UIBarButtonItem!
    @IBOutlet weak var buttonSave: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var overlayView: UIView!
    
    private var photos: PHFetchResult<PHAsset>? = nil
    
    var imageAssets: [ImageAsset] = [ImageAsset]()
    var folder: ImageFolder = ImageFolder()
    
    let numberOfItemsPerRow: CGFloat = 5
    let itemsPadding: CGFloat = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.fetchPhotosFromLibrary()
    }
    
    func setupCollectionView() {
        self.collectionView.register(UINib.init(nibName: CellIds.PhotoCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellIds.PhotoCollectionViewCell)
    }

//    private func fetchImages(assets: PHFetchResult<PHAsset>) {
//        for index in (0..<assets.count)
//        {
//            let asset = assets.object(at: index)
//            self.imageAssets.append(ImageAsset.init(asset: asset))
//
//            if self.imageAssets.count == assets.count {
//                DispatchQueue.main.async {
//                    self.activityIndicator.stopAnimating()
//                    self.collectionView.reloadData()
//                }
//            }
//        }
//    }
    
    @IBAction func buttonSaveTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.overlayView.alpha = 1
            self.activityIndicator.startAnimating()
        }
        
        DispatchQueue.global(qos: .background).async {
            let selectedAssets = self.imageAssets.filter { $0.selected == true }
            if let navigationController = self.presentingViewController as? UINavigationController,
                let folderDetailVC = navigationController.topViewController as? FolderDetailViewController {
                for selectedAsset in selectedAssets {
                    if let urlPath = FileManager.default.saveAssetToFolder(path: self.folder.path, image: selectedAsset.image) {
                        folderDetailVC.folder.images.append(ImageAsset.init(path: urlPath, name: urlPath.getThumb(path: self.folder.path)))
                    }
                }
                
                DispatchQueue.main.async {
                    folderDetailVC.collectionView.reloadData()
                    
                    self.dismissVC()
                }
            }
        }
    }
    
    @IBAction func buttonCancelTapped(_ sender: Any) {
        self.dismissVC()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK FetchPhotoViewController CollectionView DataSource

extension FetchPhotoViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getNumberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return getCell(indexPath: indexPath)
    }
}

// MARK: FetchPhotoViewController CollectionView Delegate

extension FetchPhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
            let asset = self.imageAssets[indexPath.row]
            let selected = asset.selected == true ? true : false
            
            cell.setSelected(isSelected: !selected)
            asset.selected = !selected
            self.imageAssets[indexPath.row] = asset
            
            let selectedAssets = self.imageAssets.filter { $0.selected == true }
            self.buttonSave.isEnabled = selectedAssets.count > 0
        }
    }
}

//// MARK FetchPhotoViewController CollectionView DropDelegate
//
//@available(iOS 11.0, *)
//extension FetchPhotoViewController: UICollectionViewDropDelegate {
//    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
//        if session.localDragSession != nil {
//            if collectionView.hasActiveDrag {
//                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
//            } else {
//                return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
//            }
//        } else {
//            return UICollectionViewDropProposal(operation: .forbidden)
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
//        let destinationIndexPath: IndexPath
//        if let indexPath = coordinator.destinationIndexPath {
//            destinationIndexPath = indexPath
//        } else {
//            // Get last index path of collection view.
//            let section = collectionView.numberOfSections - 1
//            let row = collectionView.numberOfItems(inSection: section)
//            destinationIndexPath = IndexPath(row: row, section: section)
//        }
//
//        switch coordinator.proposal.operation {
//        case .move:
//            //Add the code to reorder items
//            if let sourceItem = coordinator.items.last, let sourceIndexPath = sourceItem.sourceIndexPath {
//                //                self.imageAssets.swapAt(sourceIndexPath.row, destinationIndexPath.row)
//                //                collectionView.reloadItems(at: [sourceIndexPath, destinationIndexPath])
//
//                let sourceAsset = self.imageAssets[sourceIndexPath.row]
//                self.imageAssets.remove(at: sourceIndexPath.row)
//                self.imageAssets.insert(sourceAsset, at: destinationIndexPath.row)
//
//                collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
//            }
//            break
//        case .copy:
//            //Add the code to copy items
//            break
//
//        default:
//            return
//        }
//    }
//}

// MARK FetchPhotoViewController CollectionView DelegateFlowLayout

extension FetchPhotoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (collectionView.bounds.width/numberOfItemsPerRow)-itemsPadding
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemsPadding
    }
}

// MARK FetchPhotoViewController Extension

extension FetchPhotoViewController {
    func fetchPhotosFromLibrary() {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                let fetchOptions = PHFetchOptions()
                self.photos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                
                self.initArray(with: self.photos?.count ?? 0)
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.collectionView.reloadData()
                }
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                print("Not determined yet")
            case .limited:
                break
            }
        }
    }
    
    @available(iOS 11.0, *)
    func initialize() {
//        self.collectionView.dragInteractionEnabled = true
    }
    
    func registerCell() {
        self.collectionView.register(UINib.init(nibName: CellIds.PhotoCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellIds.PhotoCollectionViewCell)
    }
    
    func getCell(indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.PhotoCollectionViewCell, for: indexPath) as? PhotoCollectionViewCell {
            let imageAsset = self.imageAssets[indexPath.row]
            cell.configure(imageAsset: imageAsset, photos: photos, indexPath: indexPath)
            
            let selected = imageAsset.selected == true ? true : false
            cell.setSelected(isSelected: selected)
            
            cell.imageViewPhoto.backgroundColor = .white
            cell.resetConstraints()
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func getNumberOfItems() -> Int {
        return self.imageAssets.count
    }
    
    func initArray(with count: Int) {
        for _ in 1...count {
            self.imageAssets.append(ImageAsset())
        }
    }
}

extension UIImageView {
    func fetchImage(imageAsset: ImageAsset, asset: PHAsset, contentMode: PHImageContentMode, targetSize: CGSize) {
        guard let image = imageAsset.image else {
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.version = .original
            options.resizeMode = .exact
            
            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { image, _ in
                guard let image = image else { return }
                switch contentMode {
                case .aspectFill:
                    self.contentMode = .scaleAspectFill
                case .aspectFit:
                    self.contentMode = .scaleAspectFit
                }
                
                imageAsset.image = image
                self.image = imageAsset.image
                print("Image requested from PHImageManager")
            }
            
            return
        }
        
        self.image = image
        print("Image reloaded from ImageAsset object")
    }
}
