//
//  ZDMPAlbumsViewController.swift
//  LImitedPhotosGallery
//
//  Created by lakshmi-12493 on 08/03/22.
//

import UIKit
import PhotosUI

protocol ZDMediaPickerInternalProtocol {
    func mediaPicker(didFinishPickingMedia media : [PHAsset]? , selectionComplete : Bool)
    func mediaPicker(didFail error : ZDMediaPickerError) -> Void
    func getLocallySelectedMedia() -> [PHAsset]?
    func getSelectionLimit() -> Int?
//    func shouldDisablePanGestureForMultiSelection() -> Bool
}


class ZDMPAlbumsViewController: UIViewController {
    
    var mediaPickerLocalDelegate : ZDMediaPickerInternalProtocol? = nil
    private var albums: [PHAssetCollection] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albums.getAlbumLists()
        tableView.register(UINib(nibName: ZDMPCellId.album , bundle: Bundle(for: ZDAlbumListCell.self)), forCellReuseIdentifier: ZDMPCellId.album)
        let cancel = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelTap))
        self.navigationItem.setLeftBarButton(cancel, animated: false)
    }
    @objc private func cancelTap(){
        self.dismiss(animated: true)
    }
    
}

extension ZDMPAlbumsViewController : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ZDMPCellId.album , for: indexPath) as! ZDAlbumListCell
        cell.configure(with: albums[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigateToPhotos(with: albums[indexPath.row])
    }
    
    func navigateToPhotos(with album : PHAssetCollection){
        let vc = ZDMPUtility.instantiateViewController(withIdentifier: ZDMPViewControllerId.gallery) as! ZDMPPhotosViewController
        vc.title = album.localizedTitle
        vc.album = album
        vc.mediaPickerLocalDelegate = self.mediaPickerLocalDelegate
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
