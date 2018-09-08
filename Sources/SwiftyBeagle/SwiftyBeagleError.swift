//
//  SwiftyBeagleError.swift
//  SwiftyBeagle
//
//  Created by Konrad Feiler on 08.09.18.
//

import Foundation

enum SwiftyBeagleError: Error {
    case failedRetrievingData
    case failedParsingJSON
    case failedCreatingURL(String)
}
