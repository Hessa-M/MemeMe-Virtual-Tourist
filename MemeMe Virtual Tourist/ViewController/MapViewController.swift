//
//  ViewController.swift
//  MemeMe Virtual Tourist
//
//  Created by Hessa Mohamed on 05/02/2019.
//  Copyright © 2019 Hessa Mohamed. All rights reserved.
//


import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate{
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    var pin: Pin!
    var isEditPin = false
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var longTap: UILongPressGestureRecognizer!
    @IBOutlet weak var deletePinLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        longTap.delegate = self
        navigationItem.rightBarButtonItem = editButtonItem
        mapView.addGestureRecognizer(longTap)
        fetchPins()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.deletePinLabel.isHidden = true
    }
    
    func fetchPins() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        self.loadPins()
    }
    
    func loadPins() {
        if let fetchedPin = fetchedResultsController.fetchedObjects {
            
            var annotations = [MKPointAnnotation]()
            
            for pin in fetchedPin {
                
                let lat = CLLocationDegrees(pin.latitude)
                let long = CLLocationDegrees(pin.longitude)
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                
                annotations.append(annotation)
            }
            
            self.mapView.addAnnotations(annotations)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        deletePinLabel.isHidden = !editing
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithOtherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func getTapLocation(_ sender: UILongPressGestureRecognizer) {
        
        if longTap.state == .began {
            
            let point = longTap.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            
            let newAnnotations = MKPointAnnotation()
            newAnnotations.coordinate = coordinate
            
            self.mapView.addAnnotation(newAnnotations)
            
            addPin(coordinate: coordinate)
        }
    }
    
    func addPin(coordinate: CLLocationCoordinate2D) {
        let pin = Pin(context: DataController.shared.viewContext)
        pin.latitude = coordinate.latitude
        
        pin.longitude = coordinate.longitude
        
        self.pin = pin
        
        try? DataController.shared.viewContext.save()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "annotation"
        var pinView: MKPinAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            pinView = dequeuedView
        } else {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView.canShowCallout = false
            pinView.pinTintColor = .red
            pinView.animatesDrop = false
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            return
        }
        
        mapView.deselectAnnotation(annotation, animated: true)
        if isSavedPin(coordinate: view.annotation!.coordinate) {
            if isEditing {
                mapView.removeAnnotation(annotation)
                DataController.shared.viewContext.delete(pin)
                try? DataController.shared.viewContext.save()
                return
            }
            else {
                self.performSegue(withIdentifier: "showPhotos", sender: self)
            }
        }
    }
    
    func isSavedPin(coordinate: CLLocationCoordinate2D) -> Bool {
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
        if let savedPins = fetchedResultsController.fetchedObjects {
            for pin in savedPins {
                if pin.latitude == coordinate.latitude && pin.longitude == coordinate.longitude{
                    self.pin = pin
                    return true
                }
            }
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showPhotos" {
            if let vc = segue.destination as? PhotoViewController {
                vc.pin = self.pin
            }
        }
    }
    
}



