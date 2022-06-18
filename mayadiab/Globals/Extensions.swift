//
//  Extensions.swift
//  mayadiab
//
//  Created by MR.CHEMALY on 12/1/18.
//  Copyright © 2018 app-loads. All rights reserved.
//

import UIKit

extension UIColor {
    public convenience init?(hexString: String, alpha: CGFloat = 1) {
        assert(hexString[hexString.startIndex] == "#", "Expected hex string of format #RRGGBB")
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = hexString.substring(from: start)
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt32 = 0
                
                if scanner.scanHexInt32(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat((hexNumber & 0x0000ff)) / 255
                    a = alpha
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}

extension UIView {
    func hide(remove: Bool = false) {
        UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelNormal
        
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }, completion: { success in
            if remove {
                self.removeFromSuperview()
            }
        })
    }
    
    func show() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1
        })
    }
    
    func getImage() -> UIImage {
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}

extension Optional where Wrapped == String {
    func isNullOrEmpty() -> Bool {
        if self == nil || self == "" {
            return true
        }
        
        return false
    }
}

extension BaseViewController {
    func copyFoldersToDocuments(with name: String) -> Bool {
        let fileManager = FileManager.default
        
        let documentsUrl = fileManager.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        
        guard documentsUrl.count != 0 else {
            return false
        }

        let folderURL = documentsUrl.first!.appendingPathComponent(name)
        
        if !((try? folderURL.checkResourceIsReachable()) ?? false) {
            print("Folder does not exist in documents folder")
            
            let documentsURL = Bundle.main.resourceURL?.appendingPathComponent(name)
            
            do {
                if !FileManager.default.fileExists(atPath:folderURL.path)
                {
                    try FileManager.default.createDirectory(atPath: (folderURL.path), withIntermediateDirectories: false, attributes: nil)
                }
                return copyFiles(pathFromBundle: (documentsURL?.path)!, pathDestDocs: folderURL.path)
            } catch let error as NSError {
                print("Couldn't copy file to final location! Error:\(error.description)")
                
                return false
            }
        } else {
            print("Folder found at path: \(folderURL.path)")
        }
        
        return true
    }
    
    func copyFiles(pathFromBundle : String, pathDestDocs: String) -> Bool {
        let fileManagerIs = FileManager.default
        do {
            let filelist = try fileManagerIs.contentsOfDirectory(atPath: pathFromBundle)
            try? fileManagerIs.copyItem(atPath: pathFromBundle, toPath: pathDestDocs)
            
            for filename in filelist {
                try? fileManagerIs.copyItem(atPath: "\(pathFromBundle)/\(filename)", toPath: "\(pathDestDocs)/\(filename)")
            }
        } catch let error as NSError {
            print("\(error.description)")
            
            return false
        }
        
        return true
    }
    
    func listFilesFromDocumentsFolder(mediaPath: String) -> [String]
    {
        var urls: [String] = [String]()
        let files = FileManager.default.enumerator(atPath: mediaPath)
        
        while let file = files?.nextObject() {
            urls.append("\(mediaPath)/\(file)")
        }
        
        return urls
    }
}

extension String {
    func isDirectory() -> Bool {
        var isDir : ObjCBool = false
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: self, isDirectory:&isDir) {
            return isDir.boolValue
        } else {
            return false
        }
    }
    
    func getThumb() -> String {
        return self.lowercased().replacingOccurrences(of: " ", with: "")
    }
    
    func getThumb(path: String) -> String {
        var thumb = self
        guard let range = self.range(of: "\(path)/") else {
            return ""
        }
        
        thumb.removeSubrange(range)
        return thumb
    }
}

extension Optional where Wrapped == Substring {
    func getThumb() -> String {
        return self?.lowercased().replacingOccurrences(of: " ", with: "") ?? "logo"
    }
    
//    func getThumb(path: String) -> String {
//        var thumb = self
//        guard let range = self?.range(of: "\(path)/") else {
//            return ""
//        }
//
//        thumb.removeSubrange(range)
//        return thumb
//    }
}

extension Substring {
    func getThumb() -> String {
        return self.lowercased().replacingOccurrences(of: " ", with: "")
    }
}


extension FileManager {
    func listFoldersAndFiles(rootPath: String) -> [URL] {
        var urls = [URL]()
        let documentsUrls = self.urls(for: .documentDirectory, in: .userDomainMask)
        guard documentsUrls.count != 0 else {
            return urls
        }
        
        guard let documentsUrl = documentsUrls.first else {
            return urls
        }
        
        let folderURL = documentsUrl.appendingPathComponent(rootPath)
        
        enumerator(atPath: rootPath)?.forEach({ (path) in
            guard let strPath = path as? String else { return }
            let relativeURL = URL(fileURLWithPath: strPath, relativeTo: folderURL)
            let url = relativeURL.absoluteURL
            urls.append(url)
        })
        return urls
    }
    
    func saveAssetToFolder(path: String, image: UIImage, isOutfit: Bool = false) -> String? {
        var urlPath: String? = nil
        do {
            var fileURL: URL? = nil
            
            if isOutfit {
                let documentDirectory = try self.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                fileURL = documentDirectory.appendingPathComponent("\(path)/outfits\(randomString(length: 6))")
            } else {
                fileURL = URL.init(fileURLWithPath: path).appendingPathComponent("image\(randomString(length: 6)).png")
            }
            
            guard let _fileURL = fileURL else {
                return nil
            }
            
            if let imageData = UIImagePNGRepresentation(image) {
                try imageData.write(to: _fileURL)
                urlPath = _fileURL.path
            }
        } catch {
            print(error)
            return nil
        }
        
        return urlPath
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    func removeConstraints() {
        for constraint in self.constraints {
            self.removeConstraint(constraint)
        }
    }
}

extension UIImageView {
    func isSelected() -> Bool {
        return self.layer.borderWidth > 0
    }
    
    func setSelected(isSelected: Bool) {
        self.layer.borderWidth = isSelected ? 3 : 0
        self.layer.borderColor = isSelected ? Colors.blue.cgColor : UIColor.clear.cgColor
    }
}

extension UIView {
    func isEnabled(enable: Bool) {
        self.isUserInteractionEnabled = enable
        self.alpha = enable ? 1 : 0.5
    }
}
