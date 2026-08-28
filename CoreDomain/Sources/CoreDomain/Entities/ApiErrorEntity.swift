//
//  ApiErrorEntity.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

public struct ApiErrorEntity: Error {
    public let status: Int
    public let error: String
    public let message: String

    public init(status: Int, error: String, message: String) {
        self.status = status
        self.error = error
        self.message = message
    }
}
