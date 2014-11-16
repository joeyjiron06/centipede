//
//  Logger.swift
//  Centipede
//
//  Created by Joey Jiron Jr on 11/15/14.
//  Copyright (c) 2014 ccc. All rights reserved.
//

import Foundation

struct Logger {
	static func log(tag:String, message:String) {
		println(tag + ": " + message)
	}
}