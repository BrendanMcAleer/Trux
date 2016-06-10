//
//  DetailsViewController.swift
//  foodTruckTracker
//
//  Created by Brendan McAleer on 5/18/16.
//  Copyright © 2016 Brendan McAleer. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit


class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var annotation = MKPointAnnotation()
    var thisTruck: AnyObject?
    var truckArray = [String]()
    var daeHoLee: String?
    var i = 0
//    var fileUrl: NSURL?
    
    
    func initTruckDetailsArray(){
        
        truckArray.append(thisTruck!["name"] as! String)
        truckArray.append(thisTruck!["style"] as! String)
        truckArray.append(thisTruck!["desc"] as! String)
        if let schedule = thisTruck!["schedule"] as? NSArray{
            for i in schedule {
                if i["day"] as? String == daeHoLee {
                    truckArray.append("Hours: \(i["start"]!!) - \(i["end"]!!)")
                }
            }
        }
        
        truckArray.append(thisTruck!["site"] as! String)
        
        tableView.reloadData()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return truckArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("detailCell")!
        if i == truckArray.count - 1 {
            if let _url = NSURL(string: truckArray[i]){
                cell.textLabel?.text = String(_url)
            }
            cell.textLabel?.textColor = UIColor.blueColor()
        } else {
            cell.textLabel!.text = truckArray[i]
        }
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.textLabel?.numberOfLines = 0
        i+=1
        print("sup")
        print(i)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == truckArray.count - 1{
            if let openLink = NSURL(string: (thisTruck!["site"] as? String)!){
                UIApplication.sharedApplication().openURL(openLink)
            }
        }
    }
    
    
    
    func loadImageFromUrl(url: String, view: UIImageView){
        
        // Create Url from string
        let url = NSURL(string: url)!
        
        // Download task:
        // - sharedSession = global NSURLCache, NSHTTPCookieStorage and NSURLCredentialStorage objects.
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (responseData, responseUrl, error) -> Void in
            // if responseData is not null...
            if let data = responseData{
                
                // execute in UI thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    view.image = UIImage(data: data)
                })
            }
        }
        
        // Run task
        task.resume()
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    
    override func viewDidLoad() {
        initTruckDetailsArray()
        tableView.alwaysBounceVertical = false
        print(thisTruck, "is this truck")
        super.viewDidLoad()
        
        loadImageFromUrl(thisTruck!["img"] as! String, view: imageView)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}
