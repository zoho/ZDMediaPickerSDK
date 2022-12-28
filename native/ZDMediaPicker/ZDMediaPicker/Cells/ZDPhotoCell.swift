//
//  ZDPhotoCell.swift
//  LImitedPhotosGallery
//
//  Created by lakshmi-12493 on 06/03/22.
//

import UIKit
import Photos
class ZDPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var videoIcon: UIImageView?
    @IBOutlet weak var durationLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
    }
    
    func configure(with asset : PHAsset , hideCheckMark : Bool){
        DispatchQueue.main.async {
            self.imageView.frame = self.bounds
            self.imageView.getImageFromAsset(asset: asset)
            self.checkMark.isHidden = hideCheckMark
            self.videoIcon?.isHidden = (asset.mediaType != .video)
            self.durationLabel?.isHidden = (asset.mediaType != .video) || !hideCheckMark
            self.durationLabel?.text = (asset.mediaType == .video) ? asset.duration.timeFormatted() : nil
        }
        
    }

}
