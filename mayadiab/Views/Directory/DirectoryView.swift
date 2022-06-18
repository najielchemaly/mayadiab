//
//  DirectoryView.swift
//  mayadiab
//
//  Created by MR.CHEMALY on 12/23/18.
//  Copyright © 2018 app-loads. All rights reserved.
//

import UIKit

class DirectoryView: UIView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var folders: [ImageFolder] = [ImageFolder]()
    var parentView: EditOutfitView!
    
    class func instanceFromNib() -> UIView {
        if let directoryView = UINib(nibName: Views.DirectoryView, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView {
            return directoryView
        }
        
        return UIView()
    }

    func setupTablevView(folders: [ImageFolder]) {
        self.tableView.register(UINib.init(nibName: CellIds.DirectoryTableViewCell, bundle: nil
        ), forCellReuseIdentifier: CellIds.DirectoryTableViewCell)
        self.tableView.tableFooterView = UIView()
        
        self.folders = folders
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.folders.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.DirectoryTableViewCell) as? DirectoryTableViewCell {
            cell.labelTitle.text = self.folders[indexPath.row].name
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let url = self.folders[indexPath.row].path {
            if let editOutfitView = self.parentView {
                editOutfitView.reloadAssetsFromDirectory(url: url)
                editOutfitView.hideDirectoryView()
            } else if let mainVC = currentVC as? MainViewController {
                mainVC.activityIndicator.alpha = 1
                mainVC.activityIndicator.startAnimating()
                mainVC.reloadAssetsFromDirectory(url: url)
                mainVC.updateButtonSelectDirectories()
                mainVC.hideDirectoryView()
            }
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
