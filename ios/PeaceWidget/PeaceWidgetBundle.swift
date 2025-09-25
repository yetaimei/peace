//
//  peaceWidgetBundle.swift
//  peaceWidget
//
//  Created by 雷雷 on 2025/9/25.
//

import WidgetKit
import SwiftUI

@main
struct peaceWidgetBundle: WidgetBundle {
    var body: some Widget {
        peaceWidget()
        // 暂时禁用其他Widget类型，专注于基本功能
        // peaceWidgetControl()
        // peaceWidgetLiveActivity()
    }
}
