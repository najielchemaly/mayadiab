//
//  FolderDetailViewController.swift
//  mayadiab
//
//  Created by MR.CHEMALY on 12/15/18.
//  Copyright © 2018 app-loads. All rights reserved.
//

import UIKit

class FolderDetailViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewBottomMenu: UIView!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    
    var folder: ImageFolder = ImageFolder()
    var subfolders: [ImageFolder] = [ImageFolder]()
    var selectedAssets: [ImageAsset] = [ImageAsset]()
    var selectedFolders: [ImageFolder] = [ImageFolder]()
    
    var buttonImport: UIButton!
    var buttonSelect: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initializeViews()
        self.setupColectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.global(qos: .background).async {
            self.setupFolderDetail()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = .darkGray
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func initializeViews() {
        if let name = self.folder.name {
            self.title = name
        }
        
        self.buttonImport = UIButton(type: .system)
        self.buttonImport.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        self.buttonImport.setTitle("Import Photos", for: .normal)
        self.buttonImport.setTitleColor(.darkGray, for: .normal)
        self.buttonImport.addTarget(self, action: #selector(self.buttonImportTapped), for: .touchUpInside)
        
        self.buttonSelect = UIButton(type: .system)
        self.buttonSelect.frame = CGRect(x: 0, y: 0, width: 60, height: 44)
        self.buttonSelect.setTitle("Select", for: .normal)
        self.buttonSelect.titleLabel?.textAlignment = .right
        self.buttonSelect.setTitleColor(.darkGray, for: .normal)
        self.buttonSelect.addTarget(self, action: #selector(self.buttonSelectTapped), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: self.buttonSelect),
            UIBarButtonItem(customView: self.buttonImport)
        ]
        
        self.viewBottomMenu.isEnabled(enable: false)
        self.viewBottomMenu.alpha = 0
        self.viewHeightConstraint.constant = 0
    }
    
    @objc func buttonImportTapped() {
        if let fetchPhotoVC = storyboard?.instantiateViewController(withIdentifier: StoryboardIds.FetchPhotoViewController) as? FetchPhotoViewController {
            fetchPhotoVC.folder = folder
            self.present(fetchPhotoVC, animated: true, completion: nil)
        }
    }
    
    @objc func buttonSelectTapped() {
        if self.buttonSelect.tag == 0 {
            self.viewHeightConstraint.constant = 50
            UIView.animate(withDuration: 0.3, animations: {
                self.navigationItem.hidesBackButton = true
                self.buttonImport.isEnabled(enable: false)
                self.viewBottomMenu.isEnabled(enable: false)
                
                self.view.layoutIfNeeded()
            })
            
            self.title = "SELECT PHOTOS"
            
            self.buttonSelect.tag = 1
            buttonSelect.setTitle("Cancel", for: .normal)
        } else if self.buttonSelect.tag == 1 {
            self.viewHeightConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.navigationItem.hidesBackButton = false
                self.buttonImport.isEnabled(enable: true)
                self.viewBottomMenu.alpha = 0
                
                self.view.layoutIfNeeded()
            })
            
            if let name = self.folder.name {
                self.title = name
            }
            
            self.buttonSelect.tag = 0
            buttonSelect.setTitle("Select", for: .normal)
        }
        
        self.resetSelectedAssets()
    }
    
    func resetSelectedAssets() {
        self.folder.images.forEach { $0.selected = false }
        self.selectedAssets = [ImageAsset]()
        self.collectionView.reloadData()
    }
    
    func resetSelectedFolders() {
        
    }
    
    func setupFolderDetail() {
        self.subfolders = [ImageFolder]()
        self.folder.images = [ImageAsset]()
        
        if let mediaPath = self.folder.path {
            let urls = self.listFilesFromDocumentsFolder(mediaPath: mediaPath)
            for url in urls {
                var fileUrl = url
                guard let range = url.range(of: "\(mediaPath)/") else {
                    break
                }
                
                fileUrl.removeSubrange(range)
                if !fileUrl.contains("/") {
                    if url.isDirectory() {
                        self.subfolders.append(ImageFolder.init(path: url, name: "\(fileUrl)", thumb: fileUrl.getThumb()))
                    } else {
                        self.folder.images.append(ImageAsset.init(path: url, name: fileUrl))
                    }
                }
            }
        }
        
        self.subfolders = self.subfolders.sorted { $0.name < $1.name }
        self.folder.subfolders = self.subfolders
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    func setupColectionView() {
        self.collectionView.register(UINib(nibName: CellIds.FolderCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellIds.FolderCollectionViewCell)
        self.collectionView.register(UINib(nibName: CellIds.PhotoCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellIds.PhotoCollectionViewCell)
        self.collectionView.register(UINib(nibName: CellIds.AddCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellIds.AddCollectionViewCell)
        self.collectionView.register(UINib(nibName: CellIds.HeaderCollectionReusableView, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CellIds.HeaderCollectionReusableView)
    }
    
    //MARK Collection View Delegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.subfolders.count > 0 {
            return section == 0 ? subfolders.count + 1 : self.folder.images?.count ?? 0
        } else {
            return section == 0 ? 1 : self.folder.images?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CellIds.HeaderCollectionReusableView, for: indexPath) as? HeaderCollectionReusableView {
            sectionHeader.labelTitle.text = indexPath.section == 0 ? "FOLDERS" : "PHOTOS"
            
            return sectionHeader
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.AddCollectionViewCell, for: indexPath) as? AddCollectionViewCell {
                    return cell
                }
            } else if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.FolderCollectionViewCell, for: indexPath) as? FolderCollectionViewCell {
                let folder = self.subfolders[indexPath.row-1]
                
                if let thumb = folder.thumb {
                    let image = UIImage(named: thumb)
                    cell.imageViewIcon.image = image == nil ? UIImage(named: "folder") : image
                }
                
                if let name = folder.name {
                    if let images = folder.images, images.count > 0 {
                        let count = "("+"\(images.count)"+")"
                        cell.labelName.text = "\(name) \(count)"
                    } else {
                        cell.labelName.text = name
                    }
                }
                
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(editFolderNameTapped(sender:)))
                cell.addGestureRecognizer(longPress)
                cell.tag = indexPath.row-1
                
                return cell
            }
        case 1:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.PhotoCollectionViewCell, for: indexPath) as? PhotoCollectionViewCell {
                cell.initializeViews()
                
                if let images = self.folder.images {
                    let imageAsset = images[indexPath.row]
                    if let image = imageAsset.image {
                        cell.imageViewPhoto.image = image
                    } else if let path = imageAsset.path, !path.isEmpty {
                        if let image = UIImage(contentsOfFile: path) {
                            imageAsset.image = image
                            cell.imageViewPhoto.image = image
                        }
                    }
                    
                    if let selected = images[indexPath.row].selected {
                        cell.setSelected(isSelected: selected)
                    }
                } else {
                    cell.imageViewPhoto.image = UIImage(named: "logo")
                    cell.imageViewPhoto.backgroundColor = .white
                    
                    cell.setSelected()
                }
                
                return cell
            }
        default:
            return UICollectionViewCell()
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if self.buttonSelect.tag == 0 {
                switch indexPath.row  {
                case 0:
                    if let addFolderView = self.showView(name: Views.AddFolderView) as? AddFolderView {
                        addFolderView.initializeViews()
                        addFolderView.buttonSave.addTarget(self, action: #selector(buttonAddNewFolderTapped), for: .touchUpInside)
                    }
                    break
                default:
                    if let folderDetailViewController = storyboard?.instantiateViewController(withIdentifier: StoryboardIds.FolderDetailViewController) as? FolderDetailViewController {
                        folderDetailViewController.folder = self.subfolders[indexPath.row-1]
                        self.navigationController?.pushViewController(folderDetailViewController, animated: true)
                    }
                    break
                }
            }
            break
        case 1:
            if self.buttonSelect.tag == 0 {
                if let imageFullScreenView = self.showView(name: Views.ImageFullScreenView) as? ImageFullScreenView {
                    let imageAsset = self.folder.images[indexPath.row]
                    if let image = imageAsset.image {
                        imageFullScreenView.imageView.image = image
                        imageFullScreenView.initializeViews()
                    }
                }
            } else {
                if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                    let asset = self.folder.images[indexPath.row]
                    let selected = asset.selected == true ? true : false
                    
                    cell.setSelected(isSelected: !selected)
                    asset.selected = !selected
                    self.folder.images[indexPath.row] = asset
                    
                    self.selectedAssets = self.folder.images.filter { $0.selected == true }
                    self.viewBottomMenu.isEnabled(enable: self.selectedAssets.count > 0)
                }
            }
            break
        default:
            break
        }
    }
    
    let itemSpacing: CGFloat = 10
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
    
    @objc func editFolderNameTapped(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let alert = UIAlertController(title: "Select Option", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { action in
                if let cell = sender.view as? FolderCollectionViewCell,
                    let addFolderView = self.showView(name: Views.AddFolderView) as? AddFolderView {
                    addFolderView.initializeViews()
                    
                    addFolderView.buttonSave.setTitle("Save", for: .normal)
                    addFolderView.labelTitle.text = "Edit Folder Name"
                    
                    let folder = self.subfolders[cell.tag]
                    addFolderView.textFieldFolderName.text = folder.name
                    
                    addFolderView.buttonSave.addTarget(self, action: #selector(self.saveFolderNameTapped(sender:)), for: .touchUpInside)
                    addFolderView.buttonSave.tag = cell.tag
                }
            }))
            
//            alert.addAction(UIAlertAction(title: "Move", style: .destructive, handler: { action in
//                if let cell = sender.view as? FolderCollectionViewCell {
//                    let selectedFolder = self.subfolders[cell.tag]
//                    let fileManager = FileManager.default
//                    if let selectFolderView = self.showView(name: Views.SelectFolderView) as? SelectFolderView {
//                        selectFolderView.setupCollectionView(folder: self.folder, selectedAssets: self.selectedAssets)
//                    }
//                }
//            }))
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                if let cell = sender.view as? FolderCollectionViewCell {
                    let selectedFolder = self.subfolders[cell.tag]
                    let fileManager = FileManager.default
                    guard let urlPath = selectedFolder.path else {
                        return
                    }
                    let urlToDelete = URL(fileURLWithPath: urlPath)
                    do {
                        try fileManager.removeItem(at: urlToDelete)
                        
                        guard let indexToDelete = self.subfolders.firstIndex(where: { $0.path == selectedFolder.path }) else {
                            return
                        }
                        self.subfolders.remove(at: indexToDelete)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                        return
                    }

                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func saveFolderNameTapped(sender: UIButton) {
        if let addFolderView = customView as? AddFolderView {
            let fileManager = FileManager.default
            let selectedFolder = self.subfolders[sender.tag]
            guard let url = selectedFolder.path else {
                return
            }
            var fileUrl = url
            guard let range = fileUrl.range(of: "/\(selectedFolder.name ?? "")") else {
                return
            }
            fileUrl.removeSubrange(range)
            
            guard let newFolderName = addFolderView.textFieldFolderName.text else {
                return
            }
            
            let filePathDestination = "\(fileUrl)/\(newFolderName)"
            
            guard let filePathToMove = selectedFolder.path else {
                return
            }
            
            do {
                try fileManager.moveItem(atPath: filePathToMove, toPath: filePathDestination)
                
                selectedFolder.path = filePathDestination
                selectedFolder.name = newFolderName
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.hideView()
                }
            } catch let error as NSError {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert(message: "\(newFolderName) name already exists", style: .alert)
                }
            }
        }
    }
    
    @objc func buttonAddNewFolderTapped() {
        if let addFolderView = self.customView as? AddFolderView {
            if !addFolderView.textFieldFolderName.text.isNullOrEmpty() {
                // Get your folder path
                if let path = self.folder.path {
                    let folderPath = "\(path)/\(addFolderView.textFieldFolderName.text!)"
                    if !FileManager.default.fileExists(atPath: folderPath) {
                        // Creates that folder if no exists
                        do {
                            try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: false, attributes: nil)
                            
                            self.subfolders.append(ImageFolder.init(path: folderPath, name: addFolderView.textFieldFolderName.text!, thumb: "folder"))
                            self.folder.subfolders = self.subfolders
                            self.collectionView.reloadData()
                            self.hideView()
                        } catch let error as NSError {
                            print(error)
                        }
                    }
                }
            } else {
                addFolderView.viewFolderName.layer.borderWidth = 1
                addFolderView.viewFolderName.layer.borderColor = UIColor.red.cgColor
            }
        }
    }
    
    @IBAction func ButtonDeleteTapped(_ sender: Any) {
        if self.selectedAssets.count > 0 {
            let alert = UIAlertController(title: "Maya Diab", message: "Are you sure you want to delete the selected photos?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { alert in
                let fileManager = FileManager.default
                for selectedAsset in self.selectedAssets {
                    guard let filePath = selectedAsset.path else {
                        break
                    }
                    let fileUrlToDelete = URL(fileURLWithPath: filePath)
                    do {
                        try fileManager.removeItem(at: fileUrlToDelete)
                        
                        guard let indexToDelete = self.folder.images.firstIndex(where: { $0.path == selectedAsset.path }) else {
                            return
                        }
                        self.folder.images.remove(at: indexToDelete)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                        break
                    }
                }
                
                self.buttonSelectTapped()
                self.collectionView.reloadData()
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func buttonMoveToTapped(_ sender: Any) {
        if self.selectedAssets.count > 0 {
            if let selectFolderView = self.showView(name: Views.SelectFolderView) as? SelectFolderView {
                selectFolderView.setupCollectionView(folder: self.folder, selectedAssets: self.selectedAssets)
            }
        }
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
