//
//  Reachability.swift
//  ThoughtCastiOSRebuilt
//
//  Created by Trevor Walker on 11/4/19.
//  Copyright © 2019 Trevor Walker. All rights reserved.
//

import Foundation
import SystemConfiguration

class Reachability {
    
    private let reachability = SCNetworkReachabilityCreateWithName(nil, "www.google.com")
    
    func checkReachable() -> Bool {
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(self.reachability!, &flags)
        
        if (isNetworkReachable(with: flags))
        {
            return true
        }
        else if (!isNetworkReachable(with: flags)) {
            return false
        }
        return false
    }
    
    private func isNetworkReachable(with flags: SCNetworkReachabilityFlags) -> Bool {
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
    }
}
