//
//  Connection.swift
//  PopularMovies
//
//  Created by Alex Farcasanu on 09/05/2020.
//  Copyright © 2020 Macbook. All rights reserved.
//

import Foundation
import Reachability

class Connection {
    
    public static func internetConnectionExist() {
        //declare this property where it won't go out of scope relative to your listener
        let reachability = try! Reachability()

        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
                //return true
            } else {
                print("Reachable via Cellular")
                //return true
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            //return false
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}
