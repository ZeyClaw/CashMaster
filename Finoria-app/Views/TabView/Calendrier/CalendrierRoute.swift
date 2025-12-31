//
//  CalendrierRoute.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 14/08/2025.
//

import Foundation

enum CalendrierRoute: Hashable {
	case months(year: Int)
	case transactions(month: Int, year: Int)
}
