//
//  HomeViewController.swift
//  mayadiab
//
//  Created by MR.CHEMALY on 12/8/18.
//  Copyright © 2018 app-loads. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var buttonFolders: UIButton!
    @IBOutlet weak var buttonOutfits: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var viewOutfits: UIView!
    @IBOutlet weak var viewMenuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewMenu: UIView!
    @IBOutlet weak var buttonMove: UIButton!
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var buttonSelect: UIButton!
    @IBOutlet weak var labelOutfitsTitle: UILabel!
    
    var filteredFolders: [ImageFolder] = [ImageFolder]()
    var outfitAssets: [ImageAsset] = [ImageAsset]()
    var selectedOutfits: [ImageAsset] = [ImageAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.copyFoldersToDocuments(with: "Media") {
            self.setupFolders()
            self.initializeViews()
            self.setupColectionView()
        }
        if self.copyFoldersToDocuments(with: "Outfits") {
            self.setupOutfitAssets()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.global(qos: .background).async {
            self.getDirectories(path: "/Media")
        }
    }
    
    func setupFolders() {
        Constants.imageFolders = [ImageFolder]()
        
        if let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let mediaPath = documentDirectoryPath.appending("/Media")
            
            let urls = self.listFilesFromDocumentsFolder(mediaPath: mediaPath)
            for url in urls {
                var fileUrl = url
                guard let range = url.range(of: "\(mediaPath)/") else {
                    break
                }
                
                fileUrl.removeSubrange(range)
                print(fileUrl)
                
                if !fileUrl.contains("/") {
                    if url.isDirectory() {
                        Constants.imageFolders.append(ImageFolder.init(path: url, name: "\(fileUrl)", thumb: fileUrl.getThumb()))
                    } else {
//                        self.folder.images.append(ImageAsset.init(path: url, name: fileUrl))
                    }
                }
            }
        }
        
        Constants.imageFolders = Constants.imageFolders.sorted { $0.name < $1.name }
        self.filteredFolders = Constants.imageFolders
    }
    
    func setupOutfitAssets() {
        self.outfitAssets = [ImageAsset]()
        if let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let mediaPath = documentDirectoryPath.appending("/Outfits")
            
            let urls = self.listFilesFromDocumentsFolder(mediaPath: mediaPath)
            for url in urls {
                self.outfitAssets.append(ImageAsset.init(path: url))
            }
        }
    }
    
    func getFolderUrl(path: String, folders: [Substring], currentFolder: Substring) -> String {
        var folderUrl = path
        for folder in folders {
            folderUrl.append("/\(folder)")
            
            if folder == currentFolder {
                break
            }
        }
        
        return folderUrl
    }
    
    func initializeViews() {
        self.searchBar.delegate = self
        
        self.buttonFoldersTapped(self.buttonFolders)
        
        // Hide button move for outfits
        self.buttonMove.isHidden = true
    }
    
    func setupColectionView() {
        self.collectionView.register(UINib(nibName: CellIds.AddOutfitCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellIds.AddOutfitCollectionViewCell)
        self.collectionView.register(UINib.init(nibName: CellIds.PhotoCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellIds.PhotoCollectionViewCell)
        self.collectionView.register(UINib.init(nibName: CellIds.FolderCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellIds.FolderCollectionViewCell)
        self.collectionView.register(UINib.init(nibName: CellIds.PhotoEmptyCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellIds.PhotoEmptyCollectionViewCell)
    }
    
    //MARK Collection View Delegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.buttonOutfits.tag == 1 ? 1 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.buttonOutfits.tag == 1 ? self.outfitAssets.count + 1 : section == 0 ? self.filteredFolders.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.buttonOutfits.tag == 1 {
            switch indexPath.row {
            case 0:
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.AddOutfitCollectionViewCell, for: indexPath) as? AddOutfitCollectionViewCell {
                    return cell
                }
                break
            default:
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.PhotoCollectionViewCell, for: indexPath) as? PhotoCollectionViewCell {
                    let outfit = self.outfitAssets[indexPath.row-1]
                    
                    if let selected = outfit.selected {
                        cell.setSelected(isSelected: selected)
                    }
                    
                    if let image = UIImage.init(contentsOfFile: outfit.path) {
                        outfit.image = image
                        cell.imageViewPhoto.image = image
                    }
                    
                    cell.removeConstraints()
                    
                    return cell
                }
                break
            }
        } else {
            switch indexPath.section {
            case 0:
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.FolderCollectionViewCell, for: indexPath) as? FolderCollectionViewCell {
                    let folder = self.filteredFolders[indexPath.row]
                    
                    if let thumb = folder.thumb {
                        cell.imageViewIcon.image = UIImage(named: thumb)
                    }
                    
                    if let name = folder.name {
                        if let images = folder.images, images.count > 0 {
                            let count = "("+"\(images.count)"+")"
                            cell.labelName.text = "\(name) \(count)"
                        } else {
                            cell.labelName.text = name
                        }
                    }
                    
                    return cell
                }
            case 1:
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.PhotoEmptyCollectionViewCell, for: indexPath) as? PhotoEmptyCollectionViewCell {
                    cell.backgroundColor = .clear
                    return cell
                }
            default:
                return UICollectionViewCell()
            }
        }
        
        return UICollectionViewCell()
    }
    
    let itemSpacing: CGFloat = 10
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (collectionView.bounds.width/3)-(itemSpacing/3)
        return indexPath.section == 0 ? CGSize(width: itemWidth, height: itemWidth) : CGSize(width: collectionView.frame.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing/2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.buttonOutfits.tag == 1 {
            if self.buttonSelect.tag == 0 {
                if indexPath.row == 0 {
                    if let mainViewController = storyboard?.instantiateViewController(withIdentifier: StoryboardIds.MainViewController) as? MainViewController {
                        self.present(mainViewController, animated: true, completion: nil)
                    }
                } else {
                    if let imageFullScreenView = self.showView(name: Views.ImageFullScreenView) as? ImageFullScreenView {
                        imageFullScreenView.imageView.image = self.outfitAssets[indexPath.row-1].image
                        imageFullScreenView.initializeViews()
                    }
                }
            } else if indexPath.row > 0 {
                if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                    let outfit = self.outfitAssets[indexPath.row-1]
                    let selected = outfit.selected == true ? true : false
                    
                    cell.setSelected(isSelected: !selected)
                    outfit.selected = !selected
                    self.outfitAssets[indexPath.row-1] = outfit
                    
                    self.selectedOutfits = self.outfitAssets.filter { $0.selected == true }
                    self.viewMenu.isEnabled(enable: self.selectedOutfits.count > 0)
                }
            }
        } else {
            if let folderDetailViewController = storyboard?.instantiateViewController(withIdentifier: StoryboardIds.FolderDetailViewController) as? FolderDetailViewController {
                folderDetailViewController.folder = self.filteredFolders[indexPath.row]
                self.navigationController?.pushViewController(folderDetailViewController, animated: true)
            }
        }
    }
    
    //MARK Search Bar Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterFolders(searchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            self.filterFolders(searchText: searchText)
        }
    }
    
    func filterFolders(searchText: String) {
        self.filteredFolders = searchText.isEmpty ? Constants.imageFolders :
            Constants.imageFolders.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        
        self.collectionView.reloadData()
    }
    
    //MARK Actions

    @IBAction func buttonFoldersTapped(_ sender: Any) {
        if let button = sender as? UIButton, button.tag == 0 {
            self.buttonFolders.tag = 1
            self.buttonFolders.backgroundColor = .white
            self.buttonFolders.setTitleColor(.darkGray, for: .normal)
            
            self.buttonOutfits.tag = 0
            self.buttonOutfits.backgroundColor = .darkGray
            self.buttonOutfits.setTitleColor(.white, for: .normal)
            
            self.viewOutfits.alpha = 0
            
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func buttonOutfitsTapped(_ sender: Any) {
        if let button = sender as? UIButton, button.tag == 0 {
            self.buttonOutfits.tag = 1
            self.buttonOutfits.backgroundColor = .white
            self.buttonOutfits.setTitleColor(.darkGray, for: .normal)
            
            self.buttonFolders.tag = 0
            self.buttonFolders.backgroundColor = .darkGray
            self.buttonFolders.setTitleColor(.white, for: .normal)
            
            self.viewOutfits.alpha = 1
            
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func buttonSelectTapped(_ sender: Any) {
        if self.buttonSelect.tag == 0 {
            self.viewMenuBottomConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.viewMenu.isEnabled(enable: false)
                
                self.view.layoutIfNeeded()
            })
            
            self.labelOutfitsTitle.text = "SELECT OUTFITS"
            
            self.buttonSelect.tag = 1
            buttonSelect.setTitle("Cancel", for: .normal)
        } else if self.buttonSelect.tag == 1 {
            self.viewMenuBottomConstraint.constant = -50
            UIView.animate(withDuration: 0.3, animations: {
                self.viewMenu.alpha = 0
                
                self.view.layoutIfNeeded()
            })
            
            self.labelOutfitsTitle.text = "OUTFITS"
            
            self.buttonSelect.tag = 0
            buttonSelect.setTitle("Select", for: .normal)
        }
        
        self.resetSelectedOutfits()
    }
    
    func resetSelectedOutfits() {
        self.outfitAssets.forEach { $0.selected = false }
        self.selectedOutfits = [ImageAsset]()
        self.collectionView.reloadData()
    }
    
    @IBAction func buttonMoveTapped(_ sender: Any) {
        
    }
    
    @IBAction func buttonDeleteTapped(_ sender: Any) {
        if self.selectedOutfits.count > 0 {
            let alert = UIAlertController(title: "Maya Diab", message: "Are you sure you want to delete the selected outfits?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { alert in
                let fileManager = FileManager.default
                for selectedOutfit in self.selectedOutfits {
                    guard let filePath = selectedOutfit.path else {
                        break
                    }
                    let fileUrlToDelete = URL(fileURLWithPath: filePath)
                    do {
                        try fileManager.removeItem(at: fileUrlToDelete)
                        
                        guard let indexToDelete = self.outfitAssets.firstIndex(where: { $0.path == selectedOutfit.path }) else {
                            return
                        }
                        self.outfitAssets.remove(at: indexToDelete)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                        break
                    }
                }
                
                self.buttonSelectTapped(self.buttonSelect)
                self.collectionView.reloadData()
            }))
            
            self.present(alert, animated: true, completion: nil)
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
