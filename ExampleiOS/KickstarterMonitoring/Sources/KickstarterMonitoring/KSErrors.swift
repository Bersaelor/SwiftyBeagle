//
//  KSErrors.swift
//  KickstarterMonitoring
//
//  Created by Konrad Feiler on 13.09.18.
//

import Foundation
import SwiftyBeagle

enum KSErrors: Error {
    case projectsArrayEmpty
    case backerCountToSmall
    case emptyImage
}

extension KSErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .projectsArrayEmpty:
            return "Unexpectedtly encountered an empty array of projects"
        case .backerCountToSmall:
            return "The backer count should be bigger!"
        case .emptyImage:
            return "Imagedata was empty, problem with the image?"
        }
    }
}

extension KSErrors: HasWarningSeverity {
    var severity: ValidationStatus {
        switch self {
        case .backerCountToSmall, .emptyImage:
            return .warning
        default:
            return .error
        }
    }
}

extension KSSearchResponse: BeagleStringConvertible {
    var beagleDescription: String {
        return "\(projects.count) projects, first ones name is \"\(projects.first?.name ?? "?")\""
    }
}
