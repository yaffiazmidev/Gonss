//
//  VIPAchitecture.swift
//  Persada
//
//  Created by monggo pesen 3 on 11/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit

protocol Interactable {
    
    associatedtype DataSource: DataSourceable
    associatedtype DisplayLogic
    
    init(viewController: DisplayLogic?, dataSource: DataSource)
}

protocol Presentable {
    
    associatedtype DisplayLogic
    
    init(_ viewController: DisplayLogic?)
	
}

protocol Displayable where Self: UIViewController {
    
    associatedtype DataSource: DataSourceable
    associatedtype View: UIView
    
    init(mainView: View, dataSource: DataSource)
}

protocol DisplayableByEndpoint where Self: UIViewController {
		
	associatedtype DataSource: DataSourceable
	associatedtype View: UIView
	associatedtype Endpoint: Endpointable
		
	init(mainView: View, dataSource: DataSource, endpoint: Endpoint)
}

protocol DataSourceable {}
protocol Endpointable {}

protocol Routeable {
    
    init(_ viewController: UIViewController?)
}
