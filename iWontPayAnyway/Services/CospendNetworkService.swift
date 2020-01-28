//
//  CospendNetworkservice.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 21.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import Combine

class CospendNetworkService {
    
    static let instance = CospendNetworkService()
    
    private init(){}
    
    let staticpath = "/index.php/apps/cospend/api/projects/"
    
    var cancellable: AnyCancellable?
    
    func updateBills(project: Project, completion: @escaping ([Bill]) -> ()) {
        guard let url = buildURL(project, "bills") else {
            print("Couldn't unwrap url on server \(project.url) with project \(project.name)")
            return
        }
        URLSession.shared.dataTask(with: url, completionHandler: {
            data, response, error in
            guard let data = data else {
                print("Could not unwarp data")
                return }
            guard let bills = try? JSONDecoder().decode([Bill].self, from: data) else {
                print("Could not decode data")
                return
            }
    
            completion(bills)
            }).resume()
    }
    
    func getMembers(project: Project, completion: @escaping (Bool) -> ()) {
        guard let url = buildURL(project, "members") else {
            print("Couldn't unwrap url on server \(project.url) with project \(project)")
            completion(false)
            return
        }
        URLSession.shared.dataTask(with: url, completionHandler: {
            data, response, error in
            guard let data = data else {
                print("Could not load data")
                completion(false)
                return
            }
            guard let members = try? JSONDecoder().decode([Person].self, from: data) else {
                print("Could not decode data")
                completion(false)
                return
            }
            
            project.members = members
            completion(true)
            }).resume()
        
    }
    
    func postNewBill(project: Project, bill: Bill, completion: @escaping (Bool) -> ()) {
        guard let baseURL = buildURL(project, "bills") else {
            print("💣 Did not build URL")
            return
        }
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        let params = [
            "date": bill.date,
            "what": bill.what,
            "payer": bill.payer_id.description,
            "amount": bill.amount.description,
            "payed_for": bill.owers.map{$0.id.description}.joined(separator: ","),
            "repeat": "n",
            "paymentmode": "n",
            "categoryid": "0"
        ]
        urlComponents?.queryItems = params.map{URLQueryItem(name: $0, value: $1)}
        guard let url = urlComponents?.url else {
            completion(false)
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        cancellable = URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap {
                output in
                guard let response = output.response as? HTTPURLResponse,
                    response.statusCode == 200 else {
                        throw HTTPError.statuscode
                }
                return output.data
        }
        .sink(receiveCompletion: {
            httpCompletion in
            switch httpCompletion {
                case .finished:
                print("Successful")
                completion(true)
                break
                case .failure:
                completion(false)
                break
            }
        }, receiveValue: {
            data in
            print(data)
        })
        
        
    }
    
    func buildURL(_ project: Project, _ suffix: String) -> URL? {
        let path = "\(project.url)\(staticpath)\(project.name)/\(project.password)/\(suffix)"
        print("Building \(path)")
        return URL(string: path)
    }
    
    enum HTTPError: LocalizedError {
        case statuscode
    }
}