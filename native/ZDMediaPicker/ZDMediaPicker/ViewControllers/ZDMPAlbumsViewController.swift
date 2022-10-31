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
    func openPhotoLibrary(with delegate : ZDMediaPickerInternalProtocol? , _ scannerDelegate : ZDScanFromPhotosProtocol?)
    func mediaPicker(didFinishScanning info: [AVMetadataObject])
}


class ZDMPAlbumsViewController: UIViewController {
    
    var localDelegate : ZDMediaPickerInternalProtocol? = nil
    var scannerDelegate : ZDScanFromPhotosProtocol? = nil
    private var albums: [PHAssetCollection] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albums.getAlbumLists(isScanner: self.scannerDelegate != nil)
        tableView.register(UINib(nibName: ZDMPCellId.album , bundle: Bundle(for: ZDAlbumListCell.self)), forCellReuseIdentifier: ZDMPCellId.album)
        self.view.accessibilityIdentifier = ZDMPViewControllerId.albums
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTap))
        self.navigationItem.setLeftBarButton(cancel, animated: false)
    }
    @objc private func cancelTap(){
        self.dismiss(animated: true)
    }
    
    deinit{
        self.scannerDelegate?.didPopFromPhotos()
    }
}

extension ZDMPAlbumsViewController : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ZDMPCellId.album , for: indexPath) as! ZDAlbumListCell
        cell.configure(with: albums[indexPath.row], isScanner: self.scannerDelegate != nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigateToPhotos(with: albums[indexPath.row])
    }
    
    func navigateToPhotos(with album : PHAssetCollection){
        let vc = ZDMPUtility.instantiateViewController(withIdentifier: ZDMPViewControllerId.gallery) as! ZDMPPhotosViewController
        vc.title = album.localizedTitle
        vc.album = album
        vc.localDelegate = self.localDelegate
        vc.scannerDelegate = self.scannerDelegate
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
