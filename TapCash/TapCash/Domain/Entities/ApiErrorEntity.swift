//
//  ApiErrorEntity.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

struct ApiErrorEntity: Error {
    let status: Int
    let error: String
    let message: String
}
