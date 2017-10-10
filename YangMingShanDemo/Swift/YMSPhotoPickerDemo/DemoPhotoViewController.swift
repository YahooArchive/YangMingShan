//
//  DemoPhotoViewController.swift
//  YangMingShanDemo
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

import UIKit
import YangMingShan

class DemoPhotoViewController: UIViewController, YMSPhotoPickerViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    let cellIdentifier = "imageCellIdentifier"
    var images: NSArray! = []
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var numberOfPhotoSelectionTextField: UITextField!

    @IBAction func presentPhotoPicker(_ sender: AnyObject) {
        if self.numberOfPhotoSelectionTextField.text!.count > 0
        && UInt(self.numberOfPhotoSelectionTextField.text!) != 1 {
            let pickerViewController = YMSPhotoPickerViewController.init()

            pickerViewController.numberOfPhotoToSelect = UInt(self.numberOfPhotoSelectionTextField.text!)!

            let customColor = UIColor.init(red:248.0/255.0, green:217.0/255.0, blue:44.0/255.0, alpha:1.0)

            pickerViewController.theme.titleLabelTextColor = UIColor.black
            pickerViewController.theme.navigationBarBackgroundColor = customColor
            pickerViewController.theme.tintColor = UIColor.black
            pickerViewController.theme.orderTintColor = customColor
            pickerViewController.theme.orderLabelTextColor = UIColor.black
            pickerViewController.theme.cameraVeilColor = customColor
            pickerViewController.theme.cameraIconColor = UIColor.white
            pickerViewController.theme.statusBarStyle = .default

            self.yms_presentCustomAlbumPhotoView(pickerViewController, delegate: self)
        }
        else {
            self.yms_presentAlbumPhotoView(with: self)
        }
    }
    
    @objc func deletePhotoImage(_ sender: UIButton!) {
        let mutableImages: NSMutableArray! = NSMutableArray.init(array: images)
        mutableImages.removeObject(at: sender.tag)

        self.images = NSArray.init(array: mutableImages)
        self.collectionView.performBatchUpdates({ 
            self.collectionView.deleteItems(at: [IndexPath.init(item: sender.tag, section: 0)])
            }, completion: nil)
    }

    override func viewDidLoad() {
        let barButtonItem: UIBarButtonItem! = UIBarButtonItem.init(barButtonSystemItem: .organize, target: self, action:#selector(presentPhotoPicker(_:)))
        self.navigationItem.rightBarButtonItem = barButtonItem

        self.collectionView.register(UINib.init(nibName: "DemoImageViewCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        
    }

    // MARK: - YMSPhotoPickerViewControllerDelegate

    func photoPickerViewControllerDidReceivePhotoAlbumAccessDenied(_ picker: YMSPhotoPickerViewController!) {
        let alertController = UIAlertController.init(title: "Allow photo album access?", message: "Need your permission to access photo albumbs", preferredStyle: .alert)
        let dismissAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction.init(title: "Settings", style: .default) { (action) in
            UIApplication.shared.openURL(URL.init(string: UIApplicationOpenSettingsURLString)!)
        }
        alertController.addAction(dismissAction)
        alertController.addAction(settingsAction)

        self.present(alertController, animated: true, completion: nil)
    }

    func photoPickerViewControllerDidReceiveCameraAccessDenied(_ picker: YMSPhotoPickerViewController!) {
        let alertController = UIAlertController.init(title: "Allow camera album access?", message: "Need your permission to take a photo", preferredStyle: .alert)
        let dismissAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction.init(title: "Settings", style: .default) { (action) in
            UIApplication.shared.openURL(URL.init(string: UIApplicationOpenSettingsURLString)!)
        }
        alertController.addAction(dismissAction)
        alertController.addAction(settingsAction)

        // The access denied of camera is always happened on picker, present alert on it to follow the view hierarchy
        picker.present(alertController, animated: true, completion: nil)
    }

    func photoPickerViewController(_ picker: YMSPhotoPickerViewController!, didFinishPicking image: UIImage!) {
        picker.dismiss(animated: true) {
            self.images = [image]
            self.collectionView.reloadData()
        }
    }

    func photoPickerViewController(_ picker: YMSPhotoPickerViewController!, didFinishPickingImages photoAssets: [PHAsset]!) {

        picker.dismiss(animated: true) {
            let imageManager = PHImageManager.init()
            let options = PHImageRequestOptions.init()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
            options.isSynchronous = true

            let mutableImages: NSMutableArray! = []

            for asset: PHAsset in photoAssets
            {
                let scale = UIScreen.main.scale
                let targetSize = CGSize(width: (self.collectionView.bounds.width - 20*2) * scale, height: (self.collectionView.bounds.height - 20*2) * scale)
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options, resultHandler: { (image, info) in
                    mutableImages.add(image!)
                })
            }

            self.images = mutableImages.copy() as? NSArray
            self.collectionView.reloadData()
        }
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DemoImageViewCell! = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! DemoImageViewCell
        cell.photoImageView.image =  self.images.object(at: (indexPath as NSIndexPath).item) as? UIImage
        cell.deleteButton.tag = (indexPath as NSIndexPath).item
        cell.deleteButton.addTarget(self, action: #selector(DemoPhotoViewController.deletePhotoImage(_:)), for: .touchUpInside)

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }

}

