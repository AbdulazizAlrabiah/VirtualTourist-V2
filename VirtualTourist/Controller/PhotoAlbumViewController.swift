//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by aziz on 18/06/2019.
//  Copyright © 2019 Aziz. All rights reserved.
//

import CoreData
import UIKit

class PhotoAlbumViewController: UIViewController {
    
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    var dataController: DataController!
    var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noImagesLabel.isHidden = true
        newCollectionButton.isEnabled = false
        
        loadPhotos()
    }
    
    @IBAction func newCollectionButtonPressed(_ sender: Any) {
        
        for photoToDelete in fetchedResultsController.fetchedObjects! {
            dataController.viewContext.delete(photoToDelete)
        }
        save()
        newCollectionButton.isEnabled = false
        requestImages()
    }
    
    func loadPhotos() {
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            
            if fetchedResultsController.fetchedObjects?.count == 0 {
                requestImages()
            }
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func requestImages() {
        
        FlickrAPI.getImages(lat: pin.latitude, long: pin.longtitude, completion: { (URLs) in
            
            self.fillPhotosAndSave(URLs: URLs)
            
            if self.fetchedResultsController.sections?[0].numberOfObjects == 0 {
                self.noImagesLabel.isHidden = false
            }
            self.collectionView.reloadData()
        }) { (error) in
            self.alertFailure(message: error)
        }
    }
    
    func alertFailure(message: String) {
        
        let alertVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        showDetailViewController(alertVC, sender: nil)
    }
    
    func fillPhotosAndSave(URLs: [String]) {
        
        for (index, url) in URLs.enumerated() {
            photo = Photo(context: dataController.viewContext)
            self.photo.url = url
            self.photo.pin = pin
            save()
        }
    }
    
    func getData(url: String, indexPath: IndexPath) {
        
        FlickrAPI.getData(url: url) { (imageData) in
            self.fetchedResultsController.object(at: indexPath).image = imageData
            self.save()
        }
    }
    
    func save() {
        try? self.dataController.viewContext.save()
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Photos", for: indexPath) as! CollectionViewCell
        
        guard fetchedResultsController.object(at: indexPath).image != nil else {
            cell.activityIndicator.startAnimating()
            cell.imageView.image = nil
            self.getData(url: self.fetchedResultsController.object(at: indexPath).url!, indexPath: indexPath)
            return cell
        }
        
        let data = fetchedResultsController.object(at: indexPath).image
        cell.imageView.image = UIImage(data: data!)
        cell.activityIndicator.stopAnimating()
        
        if fetchedResultsController.fetchedObjects?.last?.image != nil {
            self.newCollectionButton.isEnabled = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let alertVC = UIAlertController(title: nil, message: "What would you like to do with the image", preferredStyle: .alert)

        alertVC.addAction(UIAlertAction(title: "Create Meme", style: .default, handler: { (alert) in
            self.changePhotoToMemedImage(indexPath: indexPath)
        }))
        
        alertVC.addAction(UIAlertAction(title: "Share", style: .default, handler: { (alert) in
            self.shareImage(indexPath: indexPath)
        }))
        
        alertVC.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (alert) in
            self.dataController.viewContext.delete(self.fetchedResultsController.object(at: indexPath))
            self.save()
        }))
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        showDetailViewController(alertVC, sender: nil)
    }
    
    func changePhotoToMemedImage(indexPath: IndexPath) {
        
        let createMemeVC = self.storyboard!.instantiateViewController(withIdentifier: "CreateMeme") as! CreateMemeVC
        let image = UIImage(data: self.fetchedResultsController.object(at: indexPath).image!)
        createMemeVC.image = image
        createMemeVC.createdMeme = { memedImage in
            self.fetchedResultsController.object(at: indexPath).image = memedImage.pngData()
            self.save()
        }
        self.present(createMemeVC, animated: true, completion: nil)
    }
    
    func shareImage(indexPath: IndexPath) {
        
        let image = self.fetchedResultsController.object(at: indexPath).image
        let activityView = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityView.completionWithItemsHandler = {(activity, completed, items, error) in
            self.dismiss(animated: true, completion: nil)
        }
        self.present(activityView, animated: true)
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
}
