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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @IBAction func nextButtonClicked(_ sender: UIBarButtonItem) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.imageView.image = photos[indexPath.row].image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowGallery", sender: indexPath)
    }
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ColorPickerViewController,
                 segue.identifier == "ShowNoteEditor", let indexPath = sender as? IndexPath{
            controller.note = Array(fileNotebook.dict.values)[indexPath.row]
            controller.addNewNote = { [weak self] (note: Note) in
                self?.fileNotebook.add(note)
            }
            controller.deleteOldNote = { [weak self] (note: Note) in
                self?.fileNotebook.remove(with: note.uid)
            }
        }
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ScrollViewController,
            segue.identifier == "ShowGallery", let indexPath = sender as? IndexPath {
            controller.photos = self.photos
        }
    }
}
