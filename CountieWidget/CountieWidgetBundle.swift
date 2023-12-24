//
//  CountieWidgetBundle.swift
//  CountieWidget
//
//  Created by Hector Carrion on 11/24/22.
//

import WidgetKit
import SwiftUI

@main
struct CountieWidgetBundle: WidgetBundle {
    var body: some Widget {
        CountieWidget1()
        CountieWidget2()
        CountieWidget3()
        CountieWidget4()
        CountieWidget5()
    }
}

//// Define a widget bundle to group the simple widgets
//@main
//struct SimpleCountieWidgetBundle: WidgetBundle {
//    var body: some Widget {
//        SimpleAccessoryInlineWidget()
//        SimpleAccessoryCircularWidget()
//        SimpleAccessoryRectangularWidget()
//    }
//}
