//
//  ViewController.swift
//  mayadiab
//
//  Created by MR.CHEMALY on 11/27/18.
//  Copyright © 2018 app-loads. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, FileManagerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentVC = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var customView = UIView()
    func showView(name: String, duration: Double = 0.3, fromWindow: Bool = true) -> UIView {
        let view = Bundle.main.loadNibNamed(name, owner: self.view, options: nil)
        if let directoryView = view?.first as? DirectoryView {
            if let mainVC = currentVC as? MainViewController {
                directoryView.frame.size.height = mainVC.viewForDirectory.frame.height
            }
            
            if fromWindow {
                appDelegate.window?.addSubview(directoryView)
            } else {
                self.view.addSubview(directoryView)
            }
            
            let originY = directoryView.frame.origin.y
            directoryView.frame.origin.y = self.view.frame.height
            UIView.animate(withDuration: duration, animations: {
                directoryView.frame.origin.y = originY
            })
            
            customView = directoryView
        } else if let subview = view?.first as? UIView {
            subview.frame = self.view.bounds
            subview.alpha = 0
            
            if fromWindow {
                appDelegate.window?.addSubview(subview)
            } else {
                self.view.addSubview(subview)
            }
            
            UIView.animate(withDuration: duration, animations: {
                subview.alpha = 1
            })
            
            customView = subview
        }
        
        UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelStatusBar
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        customView.addGestureRecognizer(tap)
        
        return customView
    }
    
    @objc func hideView() {
        self.customView.hide(remove: true)
        
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
        self.customView.endEditing(true)
    }
    
    func showAlert(title: String = "Maya Diab", message: String, style: UIAlertControllerStyle, popVC: Bool = false, dismissVC: Bool = false) {        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            if popVC {
                self.popVC()
            } else if dismissVC {
                self.dismissVC()
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func popVC(toRoot: Bool = false, fromTop: Bool = false) {
        if toRoot {
            self.navigationController?.popToRootViewController(animated: true)
        } else if fromTop {
            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromBottom
            navigationController?.view.layer.add(transition, forKey:kCATransition)
            self.navigationController?.popViewController(animated: false)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func dismissVC() {
        self.hideView()
        self.dismiss(animated: true, completion: nil)
    }
    
    func getDirectories(path: String) {
        Constants.directoryFolders = [ImageFolder]()
        if let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let mediaPath = documentDirectoryPath.appending(path)
            let urls = self.listFilesFromDocumentsFolder(mediaPath: mediaPath)
            
            for url in urls {
                if url.isDirectory() {
                    var name = url
                    guard let range = url.range(of: "\(mediaPath)/") else {
                        break
                    }
                    
                    name.removeSubrange(range)
                    
                    Constants.directoryFolders.append(ImageFolder.init(path: url, name: name, thumb: name.getThumb()))
                }
            }
            
            Constants.directoryFolders.append(ImageFolder.init(path: documentDirectoryPath.appending("/Outfits"), name: "OUTFITS"))
        }
    }
    
}

