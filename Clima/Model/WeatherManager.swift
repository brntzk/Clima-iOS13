//
//  WeatherManager.swift
//  Clima
//
//  Created by Birant Özek on 22.03.2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager,weather: WeatherModel)
    func didFailWithError(error: Error)
}
struct WeatherManager {
    let weatherURL =
        "https://api.openweathermap.org/data/2.5/weather?&appid=(API KEY))&units=metric"
    var delegate: WeatherManagerDelegate?
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    func performRequest(with urlString: String) {
        //        1. Create a URL
        if let url = URL(string: urlString) {
            //        2.Create a URLSession
            let session = URLSession(configuration: .default)
            //        3.Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                    //                    artık gerek olmayabilir selfe
                }
            }
            //        4.Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ wheatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: wheatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionid: id, cityname: name, temprature: temp)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
    
}
