//
//  Constants.swift
//  mayadiab
//
//  Created by MR.CHEMALY on 12/1/18.
//  Copyright © 2018 app-loads. All rights reserved.
//

import Foundation
import Photos
import UIKit

class Constants {
    static var imageFolders: [ImageFolder] = [ImageFolder]()
    static var directoryFolders: [ImageFolder] = [ImageFolder]()
    static var imageAssets: [ImageAsset] = [ImageAsset]()
}

class ImageAsset {
    var path: String!
    var name: String!
    var selected: Bool!
    var image: UIImage!
    var asset: PHAsset!
    
    public init(path: String = "", name: String = "", selected: Bool = false) {
        self.path = path
        self.name = name
        self.selected = selected
    }
    
    public init(image: UIImage, selected: Bool = false) {
        self.image = image
        self.selected = selected
    }
    
    public init(asset: PHAsset) {
        self.asset = asset
    }
}

class ImageFolder {
    var type: String!
    var path: String!
    var name: String!
    var thumb: String!
    var images: [ImageAsset]!
    var subfolders: [ImageFolder]!
    var isSelected: Bool!
    
    public init(type: String = AssetType.folder.rawValue, path: String = "", name: String = "", thumb: String = "", images: [ImageAsset] = [ImageAsset](), subfolders: [ImageFolder] = [ImageFolder]()) {
        self.path = path
        self.name = name
        self.thumb = thumb
        self.images = images
        self.subfolders = subfolders
    }
}
