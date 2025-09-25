//
//  peaceWidgetLiveActivity.swift
//  peaceWidget
//
//  Created by 雷雷 on 2025/9/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct peaceWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct peaceWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: peaceWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension peaceWidgetAttributes {
    fileprivate static var preview: peaceWidgetAttributes {
        peaceWidgetAttributes(name: "World")
    }
}

extension peaceWidgetAttributes.ContentState {
    fileprivate static var smiley: peaceWidgetAttributes.ContentState {
        peaceWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: peaceWidgetAttributes.ContentState {
         peaceWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: peaceWidgetAttributes.preview) {
   peaceWidgetLiveActivity()
} contentStates: {
    peaceWidgetAttributes.ContentState.smiley
    peaceWidgetAttributes.ContentState.starEyes
}
