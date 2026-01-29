//
//  DataError.swift
//  CryptoBookApp
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation

public enum DataMappingError: Error {
    case invalidNumberFormat // String -> Double 변환 실패
    case missingRequiredField
    case decodingFailed(Error)
}
