//
//  TimeFormatHelper.swift
//  Persada
//
//  Created by Muhammad Noor on 13/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

class TimeFormatHelper {
    
    static func epochConverter(date: String, epoch: Double, format: String) -> String {
        var timeResult = Double()

        if date == "" {
            timeResult = epoch / 1000
        } else {
            timeResult = Double(date)! / 1000
        }

        let date = Date(timeIntervalSince1970: timeResult)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "id_ID_POSIX")
        dateFormatter.dateFormat = format
        let localDate = dateFormatter.string(from: date)

        return localDate
    }
    
    static func epochConverterEn(date: String, epoch: Double, format: String) -> String {
        var timeResult = Double()

        if date == "" {
            timeResult = epoch / 1000
        } else {
            timeResult = Double(date)! / 1000
        }

        let date = Date(timeIntervalSince1970: timeResult)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = format
        let localDate = dateFormatter.string(from: date)

        return localDate
    }
    
    static func timeAgoString(date: Int) -> String {
        let tempDate = Date(timeIntervalSinceReferenceDate: Double(date))
        let secondsInterval = Date().timeIntervalSince(tempDate).rounded()
        if (secondsInterval < 10) {
            return "now"
        }
        if (secondsInterval < 60) {
            return String(Int(secondsInterval)) + " seconds ago"
        }
        let minutes = (secondsInterval / 60).rounded()
        if (minutes < 60) {
            return String(Int(minutes)) + " minutes ago"
        }
        let hours = (minutes / 60).rounded()
        if (hours < 24) {
            return String(Int(hours)) + " hours ago"
        }
        let days = (hours / 60).rounded()
        if (days < 30) {
            if (Int(days) == 1) {
                return "yesterday"
            }
            return String(Int(days)) + " days ago"
        }
        let months = (days / 30).rounded()
        if (months < 12) {
            return String(Int(months)) + " months ago"
        }
        let years = (months / 12).rounded()
        return String(Int(years)) + " years ago"
    }
    
    static func soMuchTimeAgo(date: Int) -> String? {

        let diff = Date().timeIntervalSince1970 - Double(date)
        var str: String = ""
        if  diff < 60 {
            str = "now"
        } else if diff < 3600 {
            let out = Int(round(diff/60))
            str = (out == 1 ? "1 minute ago" : "\(out) minutes ago")
        } else if diff < 3600 * 24 {
            let out = Int(round(diff/3600))
            str = (out == 1 ? "1 hour ago" : "\(out) hours ago")
        } else if diff < 3600 * 24 * 2 {
            str = "yesterday"
        } else if diff < 3600 * 24 * 7 {
            let out = Int(round(diff/(3600*24)))
            str = (out == 1 ? "1 day ago" : "\(out) days ago")
        } else if diff < 3600 * 24 * 7 * 4{
            let out = Int(round(diff/(3600*24*7)))
            str = (out == 1 ? "1 week ago" : "\(out) weeks ago")
        } else if diff < 3600 * 24 * 7 * 4 * 12{
            let out = Int(round(diff/(3600*24*7*4)))
            str = (out == 1 ? "1 month ago" : "\(out) months ago")
        } else {//if diff < 3600 * 24 * 7 * 4 * 12{
            let out = Int(round(diff/(3600*24*7*4*12)))
            str = (out == 1 ? "1 year ago" : "\(out) years ago")
        }
        return str
    }
	
	static func soMuchTimeAgoMini(date: Int) -> String? {

			let diff = Date().timeIntervalSince1970 - Double(date) / 1000
			var str: String = ""
			if  diff < 60 {
					str = "now"
			} else if diff < 3600 {
					let out = Int(round(diff/60))
					str = (out == 1 ? "1m" : "\(out)m")
			} else if diff < 3600 * 24 {
					let out = Int(round(diff/3600))
					str = (out == 1 ? "1h" : "\(out)h")
			} else if diff < 3600 * 24 * 2 {
					str = "1d"
			} else if diff < 3600 * 24 * 7 {
					let out = Int(round(diff/(3600*24)))
					str = (out == 1 ? "1d" : "\(out)d")
			} else if diff < 3600 * 24 * 7 * 4{
					let out = Int(round(diff/(3600*24*7)))
					str = (out == 1 ? "1w" : "\(out)w")
			} else if diff < 3600 * 24 * 7 * 4 * 12{
					let out = Int(round(diff/(3600*24*7*4)))
					str = (out == 1 ? "1m" : "\(out)m")
			} else {//if diff < 3600 * 24 * 7 * 4 * 12{
					let out = Int(round(diff/(3600*24*7*4*12)))
					str = (out == 1 ? "1y" : "\(out)y")
			}
			return str
	}
    
    static func soMuchTimeAgoNew(date: Int) -> String? {

            let diff = Date().timeIntervalSince1970 - Double(date) / 1000
            var str: String = ""
            if  diff < 60 {
                    let out = Int(round(diff))
                    str = (out == 1 ? "now" : "\(out) seconds ago")
            } else if diff < 3600 {
                    let out = Int(round(diff/60))
                    str = (out == 1 ? "1 minute ago" : "\(out) minutes ago")
            } else if diff < 3600 * 24 {
                    let out = Int(round(diff/3600))
                    str = (out == 1 ? "1 hour ago" : "\(out) hours ago")
            } else if diff < 3600 * 24 * 7 {
                    let out = Int(round(diff/(3600*24)))
                    str = (out == 1 ? "1 day ago" : "\(out) days ago")
            } else if diff < 3600 * 24 * 8 {
                    str = "1 week ago"
            } else if diff < 3600 * 24 * 365 {
                str = TimeFormatHelper.epochConverterEn(date: "", epoch: Double(date), format: "dd MMM")
            } else {
                str = TimeFormatHelper.epochConverterEn(date: "", epoch: Double(date), format: "dd MMM yyy")
            }
            return str
    }
	
	static func getDateFromTimeStamp(_ snap: Int) -> String{
			let calendar = Calendar.current
			let dateSnap = Date(timeIntervalSince1970: TimeInterval(snap))
            let diff = Calendar.current.dateComponents([.minute, .hour, .day], from: dateSnap, to: Date())
			if calendar.isDateInToday(dateSnap){
					let minute = diff.minute ?? 0
					let hour = diff.hour ?? 0
					if minute < 1{
                        return "Now"
					}
					else if hour < 1{
                        return "\(minute) minutes ago"
					}
					else{
                        return "\(hour) hour ago"
					}
			}
			else{
                let days = diff.day ?? 0
                if days <= 1{
                    return "Yesterday"
                }
                else if days < 2{
                    return "\(days) days ago"
                }
                else{
                    return TimeFormatHelper.epochConverter(date: "", epoch: Double(snap * 1000), format: "dd MMMM yyyy")
                }
			}
	}

}


func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}
