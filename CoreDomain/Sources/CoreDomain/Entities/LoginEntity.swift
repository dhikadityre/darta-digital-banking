//
//  LoginEntity.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

public struct LoginEntity {
    public let email: String
    public let displayName: String
    public let token: String

    public init(email: String, displayName: String, token: String) {
        self.email = email
        self.displayName = displayName
        self.token = token
    }
}
