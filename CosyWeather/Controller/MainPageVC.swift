//
//  ViewController.swift
//  weatherApp
//
//  Created by Shalev Lazarof on 30/06/2019.
//  Copyright © 2019 Shalev Lazarof. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class MainPageVC: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, changeCityDelegate {
    @IBOutlet weak var CityNameLabel: UILabel!
    @IBOutlet weak var TempratureLabel: UILabel!
    @IBOutlet weak var DescriptionLabel: UILabel!
    @IBOutlet weak var LastUpdateLabel: UILabel!
    @IBOutlet weak var MinTempratureLabel: UILabel!
    @IBOutlet weak var MaxTempratureLabel: UILabel!
    @IBOutlet weak var TodayLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var NextDaysTableView: UITableView!
    @IBOutlet weak var WeatherIconImageView: UIImageView!
    
    let locationManager = CLLocationManager()
    var params : [String : String] = [:]
    let WEATHER_URL = "https://api.openweathermap.org/data/2.5/forecast"
    let APP_ID = "58d039ea1106399f604aaea253627cbf"
    
    let thisDayDataModel = WeatherDataModel()
    var nextDaysDataModelsArray = [WeatherDataModel](arrayLiteral: WeatherDataModel.init(),WeatherDataModel.init(),WeatherDataModel.init(),WeatherDataModel.init(),WeatherDataModel.init())

    let date = Date()
    var calendar = Calendar.current
    let dateFormatter = DateFormatter()
    var dateComponent = DateComponents()
    
    var numOfDaysByJson : Int = 5
    var nextDaysNames = [String](repeating: .init(), count:5)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self 
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        NextDaysTableView.delegate = self
        NextDaysTableView.dataSource = self
        NextDaysTableView.showsVerticalScrollIndicator = false
        
        NextDaysTableView.register(UINib(nibName: "weatherCell", bundle: nil), forCellReuseIdentifier: "weatherCell")
    }
    
    @IBAction func MenuButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "goToSettingsPage", sender: self)
    }
    
    @IBAction func RefreshWeatherButtonPressed(_ sender: Any) {
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    @IBAction func useCurrentLocationButton(_ sender: Any) {
        locationManager.delegate = self
        locationManager.requestLocation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSettingsPage" {
            let destinationVC = segue.destination as! SettingsPageVC
            destinationVC.delegate = self
        }
    }
    
    //MARK: table view delegate methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = NextDaysTableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! weatherCell
        
        cell.TempLabel.text = "\(String(nextDaysDataModelsArray[indexPath.row].temprature))°"
        cell.DescriptionLabel.text = nextDaysDataModelsArray[indexPath.row].weatherDescription
        cell.DayLabel.text = nextDaysNames[indexPath.row]
        cell.WeatherIconImageView.image = UIImage(named: nextDaysDataModelsArray[indexPath.row].weatherIconName)
        
        cell.backgroundColor = .none
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numOfDaysByJson
    }
    
    // MARK: location manager delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
    
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            params = ["lat" : latitude, "lon" : longitude,"appid" : APP_ID]
            
            getWeatherData(url : WEATHER_URL , parameters : params)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        CityNameLabel.text = "Location Unavailable"
        TempratureLabel.text = ""
        DescriptionLabel.text = ""
        LastUpdateLabel.text = ""
    }
    
    // MARK: networking to open weather map
    func getWeatherData(url: String, parameters: [String: String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON{
            response in
            
            if response.result.isSuccess {
                print("Success, Got The Weather Data")
                let weatherJSon = JSON(response.result.value!)
                //print(weatherJSon)
                self.updateWeatherDate(json: weatherJSon)
            } else {
 
                print("Error, Connection Issues")
                self.CityNameLabel.text = "Connection Issues"
                self.TempratureLabel.text = ""
                self.DescriptionLabel.text = ""
                self.LastUpdateLabel.text = ""
            }
        }
    }
    
    // MARK: update the weather data
    func updateWeatherDate(json : JSON) {
        if json["cod"] == "404" {
            let alert = UIAlertController(title: "", message: "Wrong City Name, Please Try Again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("Wrong City Name")
            }))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            var JsonDayCounter = 0
        
            let currentDate = date.description.prefix(10)
            let JsonFirstDate = json["list"][0]["dt_txt"].stringValue.prefix(10)

            if currentDate == JsonFirstDate {
                for num in 0..<4 {
                    if currentDate == json["list"][num]["dt_txt"].stringValue.prefix(10) {
                        JsonDayCounter = JsonDayCounter + 1
                    }else {
                        break
                    }
                }
            }
            
            thisDayDataModel.cityName = json["city"]["name"].stringValue
            thisDayDataModel.temprature = Int((json["list"][0]["main"]["temp"].double)! - 273.15)
            thisDayDataModel.weatherConditionNum = json["list"][0]["weather"][0]["id"].intValue
            thisDayDataModel.weatherDescription = json["list"][0]["weather"][0]["description"].stringValue
            thisDayDataModel.weatherIconName = thisDayDataModel.updateWeatherIcon(condition: thisDayDataModel.weatherConditionNum)
        
            var minTemp : Int = Int((json["list"][0]["main"]["temp_min"].double)! - 273.15)
            var maxTemp : Int = Int((json["list"][0]["main"]["temp_max"].double)! - 273.15)
            for num in 0..<JsonDayCounter {
                if Int((json["list"][num + 1]["main"]["temp_min"].double)! - 273.15) < minTemp {
                    minTemp = Int((json["list"][num + 1]["main"]["temp_min"].double)! - 273.15)
                }
                if Int((json["list"][num + 1]["main"]["temp_max"].double)! - 273.15) > maxTemp {
                    maxTemp = Int((json["list"][num + 1]["main"]["temp_max"].double)! - 273.15)
                }
            }
            thisDayDataModel.minTemprature = minTemp
            thisDayDataModel.maxTemprature = maxTemp

            // obtain data from json for each day at 00:00
            for num in 0..<numOfDaysByJson {
                nextDaysDataModelsArray[num].temprature = Int((json["list"][JsonDayCounter]["main"]["temp"].double)! - 273.15)
                nextDaysDataModelsArray[num].weatherDescription = json["list"][JsonDayCounter]["weather"][0]["description"].stringValue
                nextDaysDataModelsArray[num].weatherConditionNum = json["list"][JsonDayCounter]["weather"][0]["id"].intValue
                nextDaysDataModelsArray[num].weatherIconName = nextDaysDataModelsArray[num].updateWeatherIcon(condition: nextDaysDataModelsArray[num].weatherConditionNum)
                JsonDayCounter = JsonDayCounter + 8
            }
            updateNextDayNames()
        
            updateTheSystemGUI()
        }
    }
    
    func updateNextDayNames () {
        dateFormatter.dateFormat = "EEEE"
        for num in 0..<numOfDaysByJson {
            nextDaysNames[num] = (String(dateFormatter.string(from: date.addingTimeInterval(TimeInterval(86400 * (num + 1))))))
        }
    }
    
    // MARK: update the UI
    func updateTheSystemGUI(){
        // next days GUI
        NextDaysTableView.reloadData()
        
        // current day GUI
        dateFormatter.dateFormat = "EEEE"
        TodayLabel.text = "\(String(dateFormatter.string(from: date))), Today"
        dateFormatter.dateFormat = "LLLL"
        calendar = Calendar.current
        DateLabel.text = "\(String(dateFormatter.string(from: date))) \(String(calendar.component(.weekday, from: date)))"
        LastUpdateLabel.text =   "Last Update \(String(Calendar.current.component(.hour, from: Date())))\(":")\(Calendar.current.component(.minute, from: Date()))"
        CityNameLabel.text = thisDayDataModel.cityName
        DescriptionLabel.text = thisDayDataModel.weatherDescription
        TempratureLabel.text = "\(thisDayDataModel.temprature)°"
        MinTempratureLabel.text = "Min: \(thisDayDataModel.minTemprature)°"
        MaxTempratureLabel.text = "Max: \(thisDayDataModel.maxTemprature)°"
        WeatherIconImageView.image = UIImage(named: thisDayDataModel.weatherIconName)
    }
    
    // MARK: change city delegate protocol method
    func userEnterCityName(city: String) {
        params = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
}
