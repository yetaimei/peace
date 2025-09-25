import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // 设置Method Channel用于Widget数据同步
    let controller = window?.rootViewController as! FlutterViewController
    let widgetChannel = FlutterMethodChannel(
      name: "com.leilei.peace/widget_sync",
      binaryMessenger: controller.binaryMessenger
    )
    
    widgetChannel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "syncLibraryData":
        self.handleSyncLibraryData(call: call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func handleSyncLibraryData(call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("📱 收到数据同步请求: \(call.method)")
    guard let args = call.arguments as? [String: Any] else {
      print("❌ 参数格式错误")
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "参数格式错误", details: nil))
      return
    }
    
    print("📱 参数: \(args)")
    
    // 同步数据到App Groups
    let userDefaults = UserDefaults(suiteName: "group.com.leilei.peace")
    
    // 将数据转换为JSON字符串存储，避免UserDefaults存储复杂对象的崩溃
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: args, options: [])
      let jsonString = String(data: jsonData, encoding: .utf8)
      userDefaults?.set(jsonString, forKey: "library_data")
      userDefaults?.set(Date(), forKey: "last_update_time")
      userDefaults?.set(args["id"] as? String, forKey: "current_answer_library")
      
      print("📱 数据已转换为JSON存储")
    } catch {
      print("❌ JSON转换失败: \(error)")
      result(FlutterError(code: "JSON_CONVERSION_ERROR", message: "数据转换失败", details: error.localizedDescription))
      return
    }
    
    // 刷新所有Widget时间线 (iOS 14.0+)
    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
    }
    
    print("📱 数据同步到Widget成功: \(args["name"] ?? "未知库")")
    result(nil)
  }
}
