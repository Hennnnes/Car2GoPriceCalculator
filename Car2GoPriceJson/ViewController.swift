//
//  ViewController.swift
//  Car2GoPriceJson
//
//  Created by Hennes Roemmer on 29.08.15.
//  Copyright © 2015 Hennes Roemmer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var price: Double = 0.00
    var durationMinutes: Int = 0
    var durationHours: Int = 0
    
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func extractJson(InputUrl: String){
        var url = NSURL(string: InputUrl)
        var data = NSData(contentsOfURL: url!)
        do {
            var jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
            var jsonString = jsonResult?.description
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
        var originValue = originTextField.text!.stringByReplacingOccurrencesOfString(", ", withString: "+").stringByReplacingOccurrencesOfString(" ", withString: "+")
        print("origin Value: \(originValue)")
        var destinationValue = destinationTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "+").stringByReplacingOccurrencesOfString(", ", withString: "+")
        print("destination value: \(destinationValue)")
        var url = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=\(originValue)+DE&destinations=\(destinationValue)+DE&mode=driving"
        print(url)
        extractJson(url)
        
        if durationHours != 0 {
            durationLabel.text = "\(durationHours) Stunden, \(durationMinutes) Minuten"
        } else {
            durationLabel.text = "\(durationMinutes) Minuten"
        }
        price = Double(durationMinutes) * 0.29 + Double(durationHours)*14.90
        priceLabel.text = "\(price) €"
        
    }

 
    
    
}

