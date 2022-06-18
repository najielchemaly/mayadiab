//
//  AppDefaults.swift
//  mayadiab
//
//  Created by MR.CHEMALY on 11/28/18.
//  Copyright © 2018 app-loads. All rights reserved.
//

import UIKit

var currentVC: UIViewController!

var appDelegate: AppDelegate {
    get {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            return delegate
        }
        
        return AppDelegate()
    }
}

enum AppStoryboard : String {
    case main
    
    var instance : UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
}

enum AssetType: String {
    case folder
    case file
}

let mainStoryboard = AppStoryboard.main.instance

struct Colors {
    static let blue: UIColor = UIColor(hexString: "#70BFFE")!
}

struct StoryboardIds {
    static let MainViewController: String = "MainViewController"
    static let HomeViewController: String = "HomeViewController"
    static let FolderDetailViewController: String = "FolderDetailViewController"
    static let FetchPhotoViewController: String = "FetchPhotoViewController"
}

struct CellIds {
    static let PhotoCollectionViewCell: String = "PhotoCollectionViewCell"
    static let PhotoEmptyCollectionViewCell: String = "PhotoEmptyCollectionViewCell"
    static let FolderCollectionViewCell: String = "FolderCollectionViewCell"
    static let HeaderCollectionReusableView: String = "HeaderCollectionReusableView"
    static let AddCollectionViewCell: String = "AddCollectionViewCell"
    static let AddOutfitCollectionViewCell: String = "AddOutfitCollectionViewCell"
    static let DirectoryTableViewCell: String = "DirectoryTableViewCell"
    static let OutfitCollectionViewCell: String = "OutfitCollectionViewCell"
    static let FetchPhotoCollectionViewCell: String = "FetchPhotoCollectionViewCell"
}

struct Views {
    static let AddFolderView: String = "AddFolderView"
    static let ImageFullScreenView: String = "ImageFullScreenView"
    static let DirectoryView: String = "DirectoryView"
    static let OutfitView: String = "OutfitView"
    static let EditOutfitView: String = "EditOutfitView"
    static let SelectFolderView: String = "SelectFolderView"
}

struct Dimensions {
    static let cornerRadiusSmall: CGFloat = 5
    static let cornerRadiusNormal: CGFloat = 10
    static let cornerRadiusMedium: CGFloat = 20
    static let cornerRadiusHigh: CGFloat = 30
}

func getYears() -> NSMutableArray {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    let strDate = formatter.string(from: Date.init())
    if let intDate = Int(strDate) {
        let yearsArray: NSMutableArray = NSMutableArray()
        for i in (1964...intDate).reversed() {
            yearsArray.add(String(format: "%d", i))
        }
        
        return yearsArray
    }
    
    return NSMutableArray()
}

func getYearsFrom(yearString: String) -> String {
    let currentYearString = Calendar.current.component(Calendar.Component.year, from: Date())
    if let year = Int(yearString) {
        let currentYear = Int(currentYearString)
        return String(currentYear-year)
    }
    
    return yearString
}

func timeAgoSince(_ date: Date) -> String {
    
    let calendar = Calendar.current
    let now = Date()
    let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
    let components = (calendar as NSCalendar).components(unitFlags, from: date, to: now, options: [])
    
    if let year = components.year, year >= 2 {
        return "\(year) years ago"
    }
    
    if let year = components.year, year >= 1 {
        return "Last year"
    }
    
    if let month = components.month, month >= 2 {
        return "\(month) months ago"
    }
    
    if let month = components.month, month >= 1 {
        return "Last month"
    }
    
    if let week = components.weekOfYear, week >= 2 {
        return "\(week) weeks ago"
    }
    
    if let week = components.weekOfYear, week >= 1 {
        return "Last week"
    }
    
    if let day = components.day, day >= 2 {
        return "\(day) days ago"
    }
    
    if let day = components.day, day >= 1 {
        return "Yesterday"
    }
    
    if let hour = components.hour, hour >= 2 {
        return "\(hour) hours ago"
    }
    
    if let hour = components.hour, hour >= 1 {
        return "An hour ago"
    }
    
    if let minute = components.minute, minute >= 2 {
        return "\(minute) minutes ago"
    }
    
    if let minute = components.minute, minute >= 1 {
        return "A minute ago"
    }
    
    if let second = components.second, second >= 3 {
        return "Just now"
    }
    
    return "Just now"
    
}
