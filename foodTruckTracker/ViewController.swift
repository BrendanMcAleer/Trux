//
//  ViewController.swift
//  foodTruckTracker
//
//  Created by Brendan McAleer on 5/18/16.
//  Copyright © 2016 Brendan McAleer. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    var locations = [NSDictionary]()
    var truckObjects = [AnyObject]()
    var daysToPick = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    //var pickedDay: String?
    var dayIndex: Int?
    
    var truckToPass: AnyObject?
    
    var today: String?
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var dayPicker: UIPickerView!
    
    
    let locationManager = CLLocationManager()
    
    func getTruck(name: String) -> AnyObject{
        print(name, "is name were passing")
        for truck in truckObjects{
            if name == truck["name"] as! String{
                print("in if")
                return truck
            }
        }
        return truckObjects[0]
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MKPointAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation as? MKAnnotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation as? MKAnnotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
    var selectedAnnotation: MKPointAnnotation!
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            selectedAnnotation = view.annotation as? MKPointAnnotation
            print(selectedAnnotation.title)
            truckToPass = getTruck(selectedAnnotation.title!)
            performSegueWithIdentifier("NextScene", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? DetailsViewController {
            destination.annotation = selectedAnnotation
            destination.thisTruck = truckToPass
            destination.daeHoLee = today
        }
    }
    
    func setPins(){
        
        let url = NSURL(string: "http://52.36.112.137/")
        // Create an NSURLSession to handle the request tasks
        let session = NSURLSession.sharedSession()
        // Create a "data task" which will request some data from a URL and then run a completion handler after it is done
        let task = session.dataTaskWithURL(url!, completionHandler: {
            data, response, error in
            // We get data, response, and error back. Data contains the JSON data, Response contains the headers and other information about the response, and Error contains an error if one occured
            // A "Do-Try-Catch" block involves a try statement with some catch block for catching any errors thrown by the try statement.
            do {
                // Try converting the JSON object to "Foundation Types" (NSDictionary, NSArray, NSString, etc.)
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSArray {
                    //print(jsonResult)
                    
                    let results = jsonResult
                    
                    for result in results {
                        self.locations.append((result as? NSDictionary)!)
                    }
                    //print(self.locations)
                    for i in self.locations {
                        for schedule in (i["schedule"] as? NSArray)! {
                            if schedule["day"] as? String == self.today {
                                //print(schedule, "this is the schedule")
                                
                                self.truckObjects.append(i)
                                
                                if let street = schedule["address"] as? String {
                                    
                                    let address = "\(street), Bellevue, WA"
                                    let geocoder = CLGeocoder()
                                    
                                    geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
                                        if((error) != nil) {
                                            print("Error", error)
                                        }
                                        
                                        if let placemark = placemarks?.first {
                                            let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                                            print(coordinates)
                                            
                                            let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(0.01 , 0.01)
                                            let location:CLLocationCoordinate2D = coordinates
                                            let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(location, theSpan)
                                            
                                            self.mapView.setRegion(theRegion, animated: true)
                                            
                                            var anotation = MKPointAnnotation()
                                            anotation.coordinate = location
                                            anotation.title = "\(i["name"]!)"
                                            anotation.subtitle = "\(i["style"]!)"
                                            self.mapView.addAnnotation(anotation)
                                            
                                            
                                        }
                                        
                                    })
                                }
                            }
                        }
                    }
                    print(self.truckObjects, "this is truck objects")
                    
                }
                
            } catch {
                print("Something went wrong")
            }
        })
        // Actually "execute" the task. This is the line that actually makes the request that we set up above
        task.resume()

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        today = "Thursday"
        
        mapView.delegate = self
        dayPicker.delegate = self
        dayPicker.dataSource = self

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        
        setPins()
    }
    
    //PICKERVIEW FUNCS
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return daysToPick.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return daysToPick[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        today = daysToPick[row]
        print(today, "is today")
        dayIndex = row
        setPins()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    Mark: Location Delegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
        
        self.mapView.setRegion(region, animated: true)
        
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Errors: " + error.localizedDescription)
    }

}

