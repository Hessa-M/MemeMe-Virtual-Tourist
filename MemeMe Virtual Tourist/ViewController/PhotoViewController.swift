//
//  PhotoViewController.swift
//  MemeMe Virtual Tourist
//
//  Created by Hessa Mohamed on 05/02/2019.
//  Copyright © 2019 Hessa Mohamed. All rights reserved.
//


import UIKit
import MapKit
import CoreData

class PhotoViewController:UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate, MKMapViewDelegate{
    
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    var pin: Pin!
    var editPhoto: Photo!
    var insertedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var isDownloadPhotos = true
    var totalPhotos = 0
    
    @IBOutlet weak var layoutFlow: UICollectionViewFlowLayout!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newPhotoButton: UIButton!
    @IBOutlet weak var deletePhotoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deletePhotoLabel.isHidden = true;
        mapView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        showPinInMap()
        setupfetchPhotos()
        
        if let photos = pin!.photo, photos.count != 0 {
            self.isDownloadPhotos = false
        }else{
            fetchPhotosFromAPI()
        }

        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupCollectionViewFlowLayout()
        setupfetchPhotos()
        self.photoCollectionView?.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
   override func setEditing(_ editing: Bool, animated: Bool) {
       super.setEditing(editing, animated: animated)
       newPhotoButton.isHidden = editing
       deletePhotoLabel.isHidden = !editing
   }
    
    func setupCollectionViewFlowLayout(){
        let space:CGFloat =  0.5
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        layoutFlow.minimumInteritemSpacing = space
        layoutFlow.minimumLineSpacing = space
        
        if self.view.frame.width < self.view.frame.height{
            layoutFlow.itemSize = CGSize( width: dimension , height: dimension)}
        else{
            layoutFlow.itemSize = CGSize( width: dimension/1.5 , height: dimension/1.5)
        }
    }
    
    func setupfetchPhotos(){
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func showPinInMap() {
        let pinAnnotation = MKPointAnnotation()
        
        let lat = CLLocationDegrees(pin.latitude)
        let long = CLLocationDegrees(pin.longitude)
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        pinAnnotation.coordinate = coordinate
        
        mapView.addAnnotation(pinAnnotation)
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        mapView.setRegion(region, animated: true)
    }
    
    func fetchPhotosFromAPI(){
        
        let lat = pin.latitude
        let lon = pin.longitude
        
        
        FlickrAPI.downloadPhotos(latitude: lat, longitude: lon) { (Photos, isdownloadSuccess , error) in
            if isdownloadSuccess {
                
                if let Photos = Photos {
                    self.totalPhotos = Photos.photos.photo.count
                    if self.totalPhotos == 0 {
                        let errorAlert = UIAlertController(title: "Erorr", message: "No photos found for this location", preferredStyle: .alert )
                        
                        errorAlert.addAction(UIAlertAction (title: "OK", style: .default, handler:
                            { _ in
                                return
                        }))
                        self.present(errorAlert, animated: true, completion: nil)
                        return
                    }else{
                        self.savePhotos(photos: Photos.photos.photo)
                    }
                }
            } else if error != nil {
                let errorAlert = UIAlertController(title: "Erorr", message: "There was an error", preferredStyle: .alert )
                
                errorAlert.addAction(UIAlertAction (title: "OK", style: .default, handler:
                    { _ in
                        return
                }))
                self.present(errorAlert, animated: true, completion: nil)
                return
            }
        }
    }
    
    func savePhotos(photos: [PhotoModel]){
        for photos in photos {
            if photos.url != nil {
                FlickrAPI.downloadImage(imageURL: photos.url!){ (Photos, isdownloadSuccess , error) in
                    if isdownloadSuccess{
                        if let data = Photos {
                            let photo = Photo(context: DataController.shared.viewContext)
                            photo.title = photos.title
                            photo.url = photos.url
                            photo.image = data
                            photo.pin = self.pin
                            try? DataController.shared.viewContext.save()
                        }
                    } else if error != nil {
                        let errorAlert = UIAlertController(title: "Erorr", message: "There was an error", preferredStyle: .alert )
                        
                        errorAlert.addAction(UIAlertAction (title: "OK", style: .default, handler:
                            { _ in
                                return
                        }))
                        self.present(errorAlert, animated: true, completion: nil)
                        return
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionInfo = self.fetchedResultsController.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("isDownloadPhotos:\(isDownloadPhotos)")
        if  self.isDownloadPhotos {
          let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
          let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
          loadingIndicator.hidesWhenStopped = true
          loadingIndicator.style = UIActivityIndicatorView.Style.gray
          loadingIndicator.startAnimating();
        
          alert.view.addSubview(loadingIndicator)
          present(alert, animated: true, completion: nil)
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionViewCell", for: indexPath) as! PhotoCollectionCell
        let aPhoto = fetchedResultsController.object(at: indexPath)

        cell.imageView.image = nil
        cell.activityIndicator.startAnimating()

        if aPhoto.image != nil {

            cell.imageView.image = UIImage(data: aPhoto.image!)
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.hidesWhenStopped = true
            if  self.isDownloadPhotos {
               dismiss(animated: true, completion: nil)
            }
            return cell
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        
        if isEditing {
                 DataController.shared.viewContext.delete(photo)
                 try? DataController.shared.viewContext.save()
                return
            }
        else {
            self.editPhoto = photo
            self.performSegue(withIdentifier: "edititorPhoto", sender: self)
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .move:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        photoCollectionView.performBatchUpdates({() -> Void in
            for indexPath in self.insertedIndexPaths {
                photoCollectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                photoCollectionView.reloadItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                photoCollectionView.deleteItems(at: [indexPath])
            }
        }, completion: nil)
    }
    
    @IBAction func newPhotos(_ sender: Any) {
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            for photo in fetchedObjects {
                DataController.shared.viewContext.delete(photo)
                try? DataController.shared.viewContext.save()
                self.isDownloadPhotos = true
            }
            fetchPhotosFromAPI()
        } else {
            print("no fetched photos")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "edititorPhoto" {
            if let vc = segue.destination as? MemeEditorViewController {
                vc.editPhoto = self.editPhoto

            }
        }
    }
}
