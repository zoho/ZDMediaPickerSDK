//
//  PHAssetExtension.swift
//  CustomMediaPicker
//
//  Created by lakshmi-12493 on 12/04/22.
//

import Foundation
import PhotosUI

struct ZDAssets {

    static func getAsset(from collection : PHAssetCollection? = nil , with filter : PHAssetMediaType? = nil) -> PHFetchResult<PHAsset>{
        let option = PHFetchOptions()
        option.sortDescriptors = [
            NSSortDescriptor(
              key: "creationDate",
              ascending: false)
          ]
        if let filter = filter {
            option.predicate = NSPredicate(format: "mediaType = %d", filter.rawValue)
        }
        if let collection = collection {
            return PHAsset.fetchAssets(in: collection, options: option)
        }
        return PHAsset.fetchAssets(with: option)
    }
}

extension UIImageView {
    
    func getImageFromAsset(asset : PHAsset){
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        option.resizeMode = PHImageRequestOptionsResizeMode.exact
        option.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize.init(width: frame.size.width*2, height: frame.size.height*2), contentMode: .aspectFill, options: option, resultHandler: { image , _ in
            if let image = image {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        })
    }
    
}

extension Array where Element == PHAssetCollection{
    mutating func getAlbumLists(isScanner : Bool){
        self.removeAll()
        
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        
        var result = Set<PHAssetCollection>()
        let option = PHFetchOptions()
        if isScanner {
            option.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        }
        [albums, smartAlbums].forEach {
            
            $0.enumerateObjects { collection, _, _ in
                if PHAsset.fetchAssets(in: collection, options: option).count > 0{
                    result.insert(collection)
                }
            }
        }
        self = Array<PHAssetCollection>(result)
    }
}



// Preview
extension UIViewController {
    
    func videoPreview(with asset : PHAsset){
        PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: nil, resultHandler: { (avAsset, audio, info) in
            DispatchQueue.main.async {
                if let avAsset = avAsset {
                    let playerItem = AVPlayerItem(asset: avAsset)
                    let player = AVPlayer(playerItem: playerItem)
                    let playerLayer = AVPlayerLayer(player: player)
                    playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                    playerLayer.masksToBounds = true
                    playerLayer.frame = self.view.bounds
                    
                    self.view.layer.addSublayer(playerLayer)
                    player.play()
                    
                }
            }
        })
    }
    
    func livePhotoPreview(with asset : PHAsset){
        let livePhotoView = PHLivePhotoView()
        let options = PHLivePhotoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic

        PHCachingImageManager.default().requestLivePhoto(
            for: asset,
            targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
            contentMode: .aspectFill,
            options: options,
            resultHandler: { (livePhoto, info) in
                if let livePhoto = livePhoto, info?[PHImageErrorKey] == nil {
                    livePhotoView.livePhoto = livePhoto
                    livePhotoView.startPlayback(with: .full)
                }
        })
        self.view = livePhotoView
        self.preferredContentSize = livePhotoView.frame.size
    }
    
    func imagePreview(with asset : PHAsset){
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.contentMode = .scaleAspectFit
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil, resultHandler: { image , _ in
            if let image = image {
                DispatchQueue.main.async {[weak self] in
                    guard self != nil else { return }
                    imageView.image = image
                }
            }
        })
        self.view = imageView
        self.preferredContentSize = imageView.frame.size
    }
}

