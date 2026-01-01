//
//  GDF_appApp.swift
//  GDF-app
//
//  Created by Godefroy REYNAUD on 03/10/2024.
//

import SwiftUI

@main
struct CashMasterApp: App {
	init() {
		// Vérifie si la permission a déjà été donnée avant de la demander
		NotificationManager.shared.requestNotificationPermission()
		NotificationManager.shared.scheduleWeeklyNotificationIfNeeded()
		NotificationManager.shared.listScheduledNotifications()
	}
	
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

