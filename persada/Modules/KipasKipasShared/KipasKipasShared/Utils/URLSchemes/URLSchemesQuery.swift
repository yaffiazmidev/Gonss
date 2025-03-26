//
//  URLSchemesQuery.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 15/11/23.
//

import Foundation

public struct URLSchemesQuery {
    public let query: String
    public let data: Dictionary<String, String>
    
    init(query: String, data: Dictionary<String, String>) {
        self.query = query
        self.data = data
    }
}
