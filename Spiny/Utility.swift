//
//  Utility.swift
//  Spiny
//
//  Created by Thibault Deutsch on 13/04/15.
//  Copyright (c) 2015 Thibault Deutsch. All rights reserved.
//

import Foundation
import SpriteKit

func mod(x: Int, m: Int) -> Int {
    let r = x % m
    return (r < 0) ? r + m : r
}