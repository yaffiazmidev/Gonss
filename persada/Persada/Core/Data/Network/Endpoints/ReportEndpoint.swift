//
//  ReportEndpoint.swift
//  Persada
//
//  Created by Muhammad Noor on 19/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum ReportEndpoint {
	case report(id: String, reasonRequest: Reason, type: String)
	case reasonReport
    case reasonReportComment
    case reasonReportSubcomment
    case reasonReportLive
	case reportsExist(id: String)
}

extension ReportEndpoint: EndpointType {

	var baseUrl: URL {
		return URL(string: APIConstants.baseURL)!
	}

	var path: String {
		switch self {
			case .report(_,_,_):
				return "/reports"
			case .reasonReport:
				return "/reports/reason/FEED"
            case .reasonReportComment:
                return "/reports/reason/comment"
            case .reasonReportSubcomment:
                return "/reports/reason/COMMENT_SUB"
            case .reasonReportLive:
                return "/reports/reason/LIVE_STREAMING"
			case .reportsExist(let id):
				return "reports/exists/target/\(id)"
		}
	}

	var method: HTTPMethod {
		switch self {
        case .reasonReport, .reasonReportComment, .reasonReportLive,.reasonReportSubcomment:
				return .get
			case .reportsExist(_): return .get
			default:
				return .post
		}
	}

	var body: [String: Any] {
		switch self {
			case .report(let id, let reason, let type):
				return [
					"reasonReport": [
						"id" : reason.id,
						"value" : reason.value,
                        "type" : reason.type
					],
					"type" : type,
					"targetReportedId" : id,
				]
				default: return [:]
		}
	}

	var header: [String : Any] {
		switch self {
			case .reportsExist(_):
				return [ "Authorization" : "Bearer \(getToken() ?? "")"]
			default:
				return [:]
		}
	}

	var parameter: [String : Any] {
		switch self {
			case .report(_,_,_), .reasonReport, .reasonReportLive:
				return [ "Authorization" : "Bearer \(getToken() ?? "")"]
			case .reportsExist(_): return [:]
            case .reasonReportComment, .reasonReportSubcomment:
                return [ "Authorization" : "Bearer \(getToken() ?? "")"]
        }
	}

}
