//
//  ImageFullScreenView.swift
//  mayadiab
//
//  Created by MR.CHEMALY on 12/23/18.
//  Copyright © 2018 app-loads. All rights reserved.
//

import UIKit

class ImageFullScreenView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // assign image...
    var image: UIImage?
    // default image width...
    private var imgWidth: CGFloat = 0.0
    // default image height...
    private var imgHeight: CGFloat = 0.0
    
    // Zoom level...
    let ZOOM_LEVEL = 2.0
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func initializeViews() {
        self.addViewComponents()
    }
    
    private func addViewComponents() {
        imgWidth = self.frame.size.width
        imgHeight = self.frame.size.height

        self.scrollView.backgroundColor = UIColor.clear
        self.scrollView.bouncesZoom = true
        self.scrollView.delegate = self
        self.scrollView.clipsToBounds = true
        self.scrollView.maximumZoomScale = 4.0
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.zoomScale = 1.0
        
        // create zoom image view...
        self.imageView.isUserInteractionEnabled = true
        self.imageView.backgroundColor = UIColor.clear
        
        // loading images...
        loadingImages()
        
        // add double tab gesture to images...
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(handleDoubleTap(gestureRecognizer:)))
        doubleTap.numberOfTapsRequired = 2
        self.imageView.addGestureRecognizer(doubleTap)
        
        // Set zoom value Max = 4.0 & Min = 1.0
        self.scrollView.contentSize = CGSize.init(width: self.imageView.bounds.width, height: self.imageView.bounds.size.height)
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    @objc private func handleDoubleTap(gestureRecognizer: UIGestureRecognizer) {
        let loImgView = gestureRecognizer.view as! UIImageView
        let loZoomView = loImgView.superview as! UIScrollView
        
        // zoom_in...
        var newScale = loZoomView.zoomScale * CGFloat(ZOOM_LEVEL)
        if newScale > loZoomView.maximumZoomScale {
            newScale = loZoomView.minimumZoomScale
        }
        else {
            newScale = loZoomView.maximumZoomScale
        }
        
        // after zoom_in or zoom_out rect...
        let zoomRect = zoomRectForScale(scale: newScale, center: gestureRecognizer.location(in: gestureRecognizer.view), sendImgView: loImgView)
        loZoomView.zoom(to: zoomRect, animated: true)
    }
    
    @IBAction func buttonCloseTapped(_ sender: Any) {
        self.hide(remove: true)
    }
    
}

extension ImageFullScreenView {
    func zoomRectForScale(scale: CGFloat, center: CGPoint, sendImgView: UIImageView) -> CGRect {
        var zoomRect = CGRect()
        // the zoom rect is in the content view's coordinates.
        //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
        //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
        zoomRect.size.height = sendImgView.frame.size.height / scale
        zoomRect.size.width = sendImgView.frame.size.width / scale
        
        // choose an origin so as to get the right center.
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
    
    func loadingImages() {
        // static image zooming...
        if self.image != nil {
            // adding images...
            self.imageView.image = self.image
            
            // image width and height calculations...
            let imageSize = imageWidth_height(image: self.imageView.image)
            self.imageView.frame = CGRect.init(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
            self.imageView.center = self.scrollView.center
        }
    }
    
    func imageWidth_height(image: UIImage?) -> (width: CGFloat, height: CGFloat) {
        // image height & weight...
        var imgWidth = image?.size.width ?? CGFloat(0)
        var imgHeight = image?.size.height ?? CGFloat(0)
        
        if imgWidth >= imgHeight {
            
            // width ratio calculating...
            let widthRatio = imgWidth/imgWidth
            let finalHeight = imgHeight/widthRatio
            
            imgWidth = self.imgWidth
            imgHeight = finalHeight
        }
        else {
            
            // height ratio calculating...
            let heightRatio = imgHeight/imgHeight
            let finalWidth = imgWidth/heightRatio
            
            imgWidth = finalWidth
            imgHeight = self.imgHeight
        }
        return (imgWidth, imgHeight)
    }
}

// MARK:-
extension ImageFullScreenView: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offset_X = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0
        let offset_Y = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0
        
        // getting scroll child as uiimageview...
        for i in 0 ..< scrollView.subviews.count {
            
            let subScroll = scrollView.subviews[i]
            if subScroll is UIImageView {
                subScroll.center = CGPoint.init(x: scrollView.contentSize.width * 0.5 + offset_X, y: scrollView.contentSize.height * 0.5 + offset_Y)
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        var scroll_child: UIView!
        for i in 0 ..< scrollView.subviews.count {
            
            // getting scroll child as uiimageview...
            let subScroll = scrollView.subviews[i]
            if subScroll is UIImageView {
                scroll_child = subScroll
                break
            }
        }
        return scroll_child
    }
}
