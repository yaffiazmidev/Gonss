//
//  ProvinceModel.swift
//  MOVANS
//
//  Created by movan on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum ProvinceModel {
  
  enum Request {
    case doSomething(item: Int)
  }
  
  enum Response {
    case doSomething(newItem: Int, isItem: Bool)
  }
  
  enum ViewModel {
    case doSomething(viewModelData: NSObject)
  }
  
  enum Route {
    case dismissProvinceScene
  }
  
  struct DataSource: DataSourceable {
    //var test: Int
  }
}
