//
//  APIConfig.swift
//  personalized-medical-learning-ios
//

import Foundation

enum APIConfig {
    /// Bonjour hostname instead of a raw LAN IP — survives DHCP reassigning the
    /// backend Mac's address (e.g. after wifi reconnect), no source edit needed.
    static let baseURL = URL(string: "http://Mikel-MacBook-Pro.local:8000")!
}
