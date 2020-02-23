//
//  MainViewController.swift
//  NotesList
//
//  Created by ios_school on 2/21/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var photos = Photo.allPhotos()
    @IBOutlet weak var collectionView: UICollectionView!
    var imagPickUp : UIImagePickerController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        let customCollectionViewLayout = UICollectionViewFlowLayout()
        customCollectionViewLayout.sectionInset = UIEdgeInsets(top: 20,
                                                               left: 20,
                                                               bottom: 20,
                                                               right: 20)
        customCollectionViewLayout.itemSize = CGSize(width: 100, height: 100)
        collectionView.setCollectionViewLayout(customCollectionViewLayout, animated: false)
        imagPickUp = self.imageAndVideos()
        title = "Галерея"
    }
    
    @IBAction func nextButtonClicked(_ sender: UIBarButtonItem) {
        buttonClicked()
    }
    
    @objc func buttonClicked() {
        let ActionSheet = UIAlertController(title: nil, message: "Select Photo", preferredStyle: .actionSheet)

        let PhotoLibrary = UIAlertAction(title: "Photo Library", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
                self.imagPickUp.mediaTypes = ["public.image"]
                self.imagPickUp.sourceType = UIImagePickerController.SourceType.photoLibrary;
                self.present(self.imagPickUp, animated: true, completion: nil)
            }

        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction) -> Void in
        })

        ActionSheet.addAction(PhotoLibrary)
        ActionSheet.addAction(cancelAction)
        self.present(ActionSheet, animated: true, completion: nil)
    
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        photos.append(Photo(image: image))
        collectionView.reloadData()
        imagPickUp.dismiss(animated: true, completion: nil)

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagPickUp.dismiss(animated: true, completion: nil)
    }
}

extension MainViewController: UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func imageAndVideos()-> UIImagePickerController{
        if(imagPickUp == nil){
            imagPickUp = UIImagePickerController()
            imagPickUp.delegate = self
            imagPickUp.allowsEditing = false
        }
        return imagPickUp
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.imageView.image = photos[indexPath.row].image
        cell.layer.borderWidth = 1
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowGallery", sender: indexPath)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ScrollViewController,
            segue.identifier == "ShowGallery", let indexPath = sender as? IndexPath {
            controller.photos = self.photos //добавить переключение экрана на выбранную картинку
            controller.hidesBottomBarWhenPushed = true
            controller.startPageNumber = indexPath.row
        }
    }
}
