//
//  ViewController.swift
//  Find My Fico
//
//  Created by Dzanan Ganic on 08/09/16.
//  Copyright © 2016 fica.io. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Moscapsule

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var myLocation:CLLocationCoordinate2D?
    
    var myMQTTClient:MyMQTTClient?
    var MQTTTopic = "gpsLocation"
    
    var carAnnotation:CarAnnotation?
    var carAnnotationTitle = "Coolest car ever"
    var carAnnotationSubtitle = "ever ever ever"
    var carAnnotationImageName = "fico_icon_small.png"
    
    var refreshMap:Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        carAnnotation = CarAnnotation(title: carAnnotationTitle, subtitle: carAnnotationSubtitle, imageName: carAnnotationImageName)
        
        initializeMQTT()
        initializeLocationManager()
        initializeMapView()
    }
    
    func initializeLocationManager(){
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func initializeMapView(){
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
    }
    
    func initializeMQTT(){
        myMQTTClient = MyMQTTClient()
        
        myMQTTClient?.updateMapCallback = {
            print("\($0) and \($1)")
            self.refreshMap = true
            self.updateCarAnnotation(lat: Double($0), lon: Double($1))
        }
        
        myMQTTClient?.connect()
        myMQTTClient?.subscribe(topic: MQTTTopic)
    }
    
    func updateCarAnnotation(lat:Double, lon:Double){
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.carAnnotation?.coordinate = CLLocationCoordinate2DMake(lat, lon)
                self.mapView.addAnnotation(self.carAnnotation!)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        mapView.showsUserLocation = true;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapView.showsUserLocation = false
        myMQTTClient?.disconnect()
    }
    
    func resetTracking(){
        if (mapView.showsUserLocation){
            mapView.showsUserLocation = false
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func saveCurrentLocation(_ center:CLLocationCoordinate2D){
        let message = "\(center.latitude) , \(center.longitude)"
        print(message)
        myLocation = center
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if(self.refreshMap){
            if(self.mapView.annotations.count>=2){
                self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            } else {
                let location = locations.last
                let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))
                
                self.mapView.setRegion(region, animated: true)
            }
            self.refreshMap = false
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if let annotation = annotation as? CarAnnotation{
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation")
            if view == nil {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
                view!.image = UIImage(named:carAnnotationImageName)
                view!.canShowCallout = true
            }
            else {
                view!.annotation = annotation
            }
            
            return view
        }
        return nil
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
