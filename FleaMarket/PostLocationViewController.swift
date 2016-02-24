//
//  PostLocationViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 25/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class PostLocationViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var location:UIImage = UIImage(named: "location.png")!
    var currentLocation:String!
    var currentCity:String?
    var currentCountry:String?
    var currentCountryCode:String?
    var currentPlacemark:CLPlacemark?
    var list:[(String,String,String,CLPlacemark)] = []
    var callback:(String,String,String,CLPlacemark)->Void = {(_,_,_,_) in}
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
        
        self.currentLocation = " 正在定位"
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.edgesForExtendedLayout = UIRectEdge.None
        self.tableView.registerNib(UINib(nibName: "PostLocationTableViewCell", bundle: nil), forCellReuseIdentifier: "PostLocationTableViewCell")
        self.tableView.registerNib(UINib(nibName: "PostAutoLocateTableViewCell", bundle: nil), forCellReuseIdentifier: "PostAutoLocateTableViewCell")
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }else{
            currentLocation = " 定位失败，未开启定位服务"
        }
    }


    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section==0{
            return 1
        }
        return list.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier("PostAutoLocateTableViewCell", forIndexPath: indexPath) as! PostAutoLocateTableViewCell
            
            cell.setupCell(location, string: currentLocation)
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("PostLocationTableViewCell", forIndexPath: indexPath) as! PostLocationTableViewCell
        cell.setupCell(list[indexPath.row].0+", "+list[indexPath.row].1)
        return cell
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        CLGeocoder().reverseGeocodeLocation(location){
            (placemarks,error) in
            if placemarks == nil{
                self.currentLocation = " 定位失败"
                
                self.locationManager.stopUpdatingLocation()
                self.tableView.reloadData()
            }else{
                if placemarks![0].locality != nil{
                    self.currentCity = placemarks![0].locality!
                }else{
                    self.currentCity = placemarks![0].name!
                }
                self.currentLocation = " "+self.currentCity!+", "+placemarks![0].country!
                self.currentCountry = placemarks![0].country!
                self.currentCountryCode = placemarks![0].ISOcountryCode!
                self.currentPlacemark = placemarks![0]
                self.locationManager.stopUpdatingLocation()
                self.tableView.reloadData()
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchBar.text!, inRegion: nil, completionHandler: {
            (placemarks,error) in
            self.list = []
            if placemarks == nil{
                self.tableView.reloadData()
                print("None found.")
                return
            }
            for placemark in placemarks!{
                self.list.append((placemark.locality != nil ? placemark.locality! : placemark.name!,placemark.country!,placemark.ISOcountryCode!,placemark))
            }
            self.tableView.reloadData()
        })
    }
    
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "当前位置"
        }
        return "搜索结果"
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 && indexPath.row == 0 && currentCity == nil {
            return false
        }else{
            return true
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0{
            if currentCity != nil{
                callback(currentCity!,currentCountry!,currentCountryCode!,currentPlacemark!)
                self.navigationController?.popViewControllerAnimated(true)
            }
            return
        }
        
        callback(list[indexPath.row].0,list[indexPath.row].1,list[indexPath.row].2,list[indexPath.row].3)
        self.navigationController?.popViewControllerAnimated(true)
    }
}
