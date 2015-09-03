//
//  ViewController.swift
//  Car2GoPriceJson
//
//  Created by Hennes Roemmer on 29.08.15.
//  Copyright © 2015 Hennes Roemmer. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var price: Double = 0.00
    var durationMinutes: Int = 0
    var durationHours: Int = 0
    var originValue: String = "test"
    var destinationValue: String = ""
    let locationManager = CLLocationManager()
    var originAdress: String = ""
    
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
        Location Stuff happens here
    */
    @IBAction func getLocation(sender: AnyObject) {
        // For foreground user
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.stopUpdatingLocation()
        }

    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        originValue = "\(locValue.latitude),\(locValue.longitude)"
        print(originValue)
        let originURL = "https://maps.googleapis.com/maps/api/geocode/json?address=\(originValue)"
        let url = NSURL(string: originURL)
        let data = NSData(contentsOfURL: url!)
        do {
            let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
            let jsonString = jsonResult?.description
            var jsonSubString1 = jsonString!.componentsSeparatedByString("\"formatted_address\" = \"")
            let jsonSubString2 = jsonSubString1[1].componentsSeparatedByString(",")
            let jsonSubString3 = jsonSubString2[0].componentsSeparatedByString("\n")
            originTextField.text = "\(jsonSubString3[0])"
        } catch let error as NSError {
            print(error)
        }
        
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("failed")
    }
    /*
        Location stuff over
    */
    
    
    func extractJson(InputUrl: String){
        let url = NSURL(string: InputUrl)
        let data = NSData(contentsOfURL: url!)
        do {
            let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
            let jsonString = jsonResult?.description
            var jsonSubString1 = jsonString!.componentsSeparatedByString("duration")
            var jsonSubString2 = jsonSubString1[1].componentsSeparatedByString("}")
            var jsonSubString3 = jsonSubString2[0].componentsSeparatedByString("=")
            var jsonSubString4 = jsonSubString3[2].componentsSeparatedByString("\"")
            var jsonSubString5 = jsonSubString4[1].componentsSeparatedByString(" ")
            if jsonSubString5.count == 4 {
                durationHours = Int(jsonSubString5[0])!
                durationMinutes = Int(jsonSubString5[2])!
            } else if jsonSubString5.count == 2 {
                durationHours = 0
                durationMinutes = Int(jsonSubString5[0])!
            }
        } catch let error as NSError {
            print(error)
        }
        
    }
    
    
    @IBAction func getDurationAndPrice(sender: AnyObject) {
        
         originValue = originTextField.text!.stringByReplacingOccurrencesOfString(", ", withString: "+").stringByReplacingOccurrencesOfString(" ", withString: "+")
         originValue = "\(originValue)+DE"
        
        print("origin Value: \(originValue)")
        destinationValue = destinationTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "+").stringByReplacingOccurrencesOfString(", ", withString: "+")
        print("destination value: \(destinationValue)")
        let url = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=\(originValue)&destinations=\(destinationValue)+DE&mode=driving"
        print(url)
        extractJson(url)
        
        if durationHours != 0 {
            durationLabel.text = "\(durationHours) Stunden, \(durationMinutes) Minuten"
        } else {
            durationLabel.text = "\(durationMinutes) Minuten"
        }
        price = Double(durationMinutes) * 0.29 + Double(durationHours)*14.90
        priceLabel.text = "\(price) €"
        DismissKeyboard()
    }

 
    
    
}

