//
//  AppDelegate.swift
//  BackgroundTask
//
//  Created by Steve_Mac on 2020/7/18.
//  Copyright © 2020 goertek. All rights reserved.
//

import UIKit
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // 在info.plist中定义的ID
    let kRefreshTaskId = "com.chadai.com.test.backgroundmodel.fetch"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 13.0, *) {
            
            let isRegistered = BGTaskScheduler.shared.register(forTaskWithIdentifier: kRefreshTaskId, using: nil) { (bgTask) in
                //
                self.handleRefreshAction(task: bgTask)
            }
            
            if isRegistered {
                print("BGTaskScheduler is registered!")
            }else {
                print("BGTaskScheduler register failed!")
            }
            
        }else {
            // < 13.0 step 1
            application.setMinimumBackgroundFetchInterval(20 * 60)
            
        }
        
        let filePath = NSHomeDirectory() + "/Documents" + "/QiLog.txt"
        print(filePath)

        return true
    }
    
    
    // < 13.0 step 2
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // 执行唤醒操作
        // ...
        fetchAction(fetchInfo: #function)
        completionHandler(.newData)
        
    }
    
    @available(iOS 13.0, *)
    func handleRefreshAction(task:BGTask) {
        
        scheduleAppRefreshAction()
        
        fetchAction(fetchInfo: #function)
        
    }
    
    @available(iOS 13.0, *)
    func scheduleAppRefreshAction() {
        fetchAction(fetchInfo: #function)
        let request = BGAppRefreshTaskRequest.init(identifier: kRefreshTaskId)
        request.earliestBeginDate = NSDate.init(timeIntervalSinceNow: 15 * 60) as Date
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch let err as NSError {
            print(err)
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if #available(iOS 13.0, *) {
            scheduleAppRefreshAction()
        }
    }
    
    // APP唤醒时的执行任务
        func fetchAction(fetchInfo:String) {
            
            print(#function)
//            let fileU = FileUtil.init()
//
//            let date = Date.init()
//            let format = DateFormatter.init()
//            format.dateFormat = "yyyy-MMdd-HH:mm:ss"
//            let dStr = format.string(from: date)  + "  :  " + fetchInfo + "\n\n"
//
//    //        fileU.createLogDirectory(direPath: fileU.logPath! + "/" + dStr)
//            fileU.createLogFile(filePath: fileU.logPath! + "/fetch.txt", fileData: dStr.data(using: .utf8))
            
            let date = Date.init()
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyy-MM-dd HH:mm"
            let timeString = dateFormatter.string(from: date)
            
            let filePath = NSHomeDirectory() + "/Documents" + "/QiLog.txt"
            print(filePath)
            if !FileManager.default.fileExists(atPath: filePath) {
                let data = timeString.data(using: .utf8)
                FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
            }else {
                var data = NSData.init(contentsOfFile: filePath)
                let originalContent = String.init(data: data! as Data, encoding: .utf8)
                let content = originalContent! + String.init(format: "\n 时间  %@ - %@\n", timeString,fetchInfo)
                data = content.data(using: .utf8) as NSData?
                data?.write(toFile: filePath, atomically: true)
            }
            
        }


}

