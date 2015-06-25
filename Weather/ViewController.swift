//
//  ViewController.swift
//  Weather
//
//  Created by 刘伟龙 on 15/6/25.
//  Copyright (c) 2015年 刘伟龙. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager:CLLocationManager = CLLocationManager()
    
    
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var weatherState: UIImageView!
    
    @IBOutlet weak var tempreture: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if(ios8())
        {
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
    {
        var location:CLLocation = locations[locations.count-1] as! CLLocation
        if(location.horizontalAccuracy > 0)
        {
            println(location.coordinate.latitude)
            println(location.coordinate.longitude)
            
            self.updateWeatherInfo(location.coordinate.latitude, longitude:location.coordinate.longitude)
            
            
            locationManager.stopUpdatingLocation()
        }
    }
    
    func updateWeatherInfo(latitude:CLLocationDegrees, longitude:CLLocationDegrees)
    {
        let manager = AFHTTPRequestOperationManager()
        let url = "http://api.openweathermap.org/data/2.5/weather"
        
        let params = ["lat":latitude, "lon":longitude, "cnt":0]
        
        manager.GET(url, parameters: params, success: {
            (operation:AFHTTPRequestOperation!, respondsObject:AnyObject!) in
            println("JSON: " + respondsObject.description!)
            
            self.updateUISuccess(respondsObject as! NSDictionary!)
            },
            failure: {
                (opertion:AFHTTPRequestOperation!, error:NSError!) in
                println("Error: " + error.localizedDescription)
        })
    }
    
    func updateUISuccess(jsonResult:NSDictionary!)
    {
        //获取城市温度
        if let tempResult = jsonResult["main"]?["temp"] as? Double{
            var temperature: Double = 0.0
            if (jsonResult["sys"]?["country"] as! String == "US"){
                temperature = round(((tempResult - 273.15) * 1.8) + 32)
            }
            else{
                temperature = round(tempResult - 273.15)
            }
            
            self.tempreture.text = "\(temperature)°"
            self.tempreture.font = UIFont.boldSystemFontOfSize(60)
        }
        else{
            
        }
        
        //获取城市名称
        if let cityName = jsonResult["name"] as? String{
            self.locationName.text = cityName
        }
        else{
        }
        
        //获取时间段
        var condition = (jsonResult["weather"] as! NSArray)[0]["id"] as! Int
        var sunrise = jsonResult["sys"]?["sunrise"] as? Double
        var sunset = jsonResult["sys"]?["sunset"] as? Double
        
        var bNightTime = false
        var now = NSDate().timeIntervalSince1970
        
        if(now < sunrise || now > sunset)
        {
            bNightTime = true;
        }
        
        self.updateWeatherIcon(condition, bNightTime:bNightTime)
    }
    
    func updateWeatherIcon(condition: Int, bNightTime:Bool)
    {
        if(condition < 300)
        {
            if bNightTime{
                self.weatherState.image = UIImage(named: "Weather_Forecast_yellow_11")
            }
            else{
                self.weatherState.image = UIImage(named: "Weather_Forecast_yellow_10")
            }
        }
        else if(condition < 500){
            self.weatherState.image = UIImage(named: "Weather_Forecast_yellow_12")
        }
        else{
            self.weatherState.image = UIImage(named: "Weather_Forecast_yellow_13")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!)
    {
        println(error)
    }

    func ios8() ->Bool{
        return UIDevice.currentDevice().systemVersion == "8.3"
    }

}

