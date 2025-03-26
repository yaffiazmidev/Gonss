//
//  TrackingShipmentModel.swift
//  KipasKipas
//
//  Created by movan on 18/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum TrackingShipmentModel {
	
	enum Request {
		case fetchTracking(id: String)
	}
	
	enum Response {
		case trackingShipment(result: TrackingShipmentResult)
	}
	
	enum ViewModel {
		case trackingShipment(viewModel: [HistoryTracking])
	}
	
	enum Route {
		case dismissTrackingShipmentScene
	}
	
	struct DataSource: DataSourceable {
		var id: String?
		var data: [HistoryTracking]?
	}
}
