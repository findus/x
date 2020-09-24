//
//  TripHandler.swift
//  Trainspot.App
//
//  Created by Philipp Hentschel on 15.09.20.
//  Copyright © 2020 Philipp Hentschel. All rights reserved.
//

import Foundation
import TripVisualizer
import CoreLocation
import SwiftEventBus

//TODO proxy holder for controller, right now it is hardcoded for only one controller, if multiple should be supported this class must be extended to support 1 to n Controllers
public class TripHandler {
    
    private let manager = TrainLocationProxy.shared
    public static let shared = TripHandler()
    private var tripTimeFrameLocationController = TrainLocationTripByTimeFrameController()
    public var demoTimer: TimeTraveler?
    private var selectedTrip: String?
    private var updateTimer: Timer? {
        didSet {
            Log.info("Invalidate Selected-Trip-Refresh Timer and restart it")
            oldValue?.invalidate()
        }
    }
    
    private init() {
        self.setupBus()
        #if MOCK
        self.setupDemo()
        #else
        tripTimeFrameLocationController.setDataProvider(withProvider: TripProvider(NetworkTrainDataTimeFrameProvider()))
        #endif
        
        self.manager.register(controller: tripTimeFrameLocationController)
        
        self.updateTimer = self.startUpdateTimer()
    }
    
    func setupDemo() {
        //TODO distinct between demo mode and mocking-debug mode
        var components = DateComponents()
        components.second = 12
        components.hour = 16
        components.minute = 40
        components.day = 12
        components.month = 6
        components.year = 2020
        let date = Calendar.current.date(from: components)
        let traveler = TimeTraveler()
        self.demoTimer = traveler
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            traveler.travel(by: 1)
        }
        traveler.date = date!
        self.tripTimeFrameLocationController.pause()

        tripTimeFrameLocationController.setDataProvider(withProvider: TripProvider(MockTrainDataTimeFrameProvider(withFile: "wfb_trip_25_min_delay_to_bs")))
        tripTimeFrameLocationController.dateGenerator = traveler.generateDate
        
        // Hildesheim
        let loc = CLLocation(latitude: 52.161407, longitude: 9.938503)
        tripTimeFrameLocationController.setCurrentLocation(location: loc)
        UserLocationController.shared.deactivate()
        UserPrefs.setManualLocationEnabled(true)
        UserPrefs.setHasUserActivatedManualLocation(true)
      //  UserPrefs.setManualLocation(loc)
        UserPrefs.setSelectedStation(StationInfo("Braunschweig Hbf", "8000049"))
    }
    
    func start() {
        self.triggerUpdate()
    }
    
    func stop() {
        self.tripTimeFrameLocationController.pause()
    }
    
    func forceStart() {
        self.tripTimeFrameLocationController.fetchServer()
    }
    
    func triggerUpdate() {
        
        self.updateTimer = self.startUpdateTimer()
        if UserPrefs.getfirstOnboardingTriggered() == true {
            self.tripTimeFrameLocationController.fetchServer()
        }
    }
    
    func triggerRefreshForTrips(_ trips: Array<TimeFrameTrip>) {
        self.updateTimer = self.startUpdateTimer()
        self.tripTimeFrameLocationController.refreshSelected(trips: trips)
    }
    
    func setCurrentLocation(_ location: CLLocation) {
        self.tripTimeFrameLocationController.setCurrentLocation(location: location)
    }
    
    func setSelectedTripID(_ tripID: String?) {
        self.selectedTrip = tripID
    }
    
    func getSelectedTripID() -> String? {
        return self.selectedTrip
    }
    
    private func setupBus() {
        SwiftEventBus.onMainThread(self, name: "selectTripOnMap") { (notification) in
            if let trip = notification?.object as? Trip {
                
                TripHandler.shared.setSelectedTripID(trip.tripId)
                TripHandler.shared.triggerRefreshForTrips([trip as! TimeFrameTrip])
            } else if let tripID = notification?.object as? String {
                TripHandler.shared.setSelectedTripID(tripID)
                if let trip = self.tripTimeFrameLocationController.getTrip(withID: tripID) {
                    TripHandler.shared.triggerRefreshForTrips([trip])
                }
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "deSelectTripOnMap") { (notification) in
            TripHandler.shared.setSelectedTripID(nil)
        }
    }
    
    private func startUpdateTimer() -> Timer  {
        return Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { (timer) in
            guard let selectedTripID = self.selectedTrip, let trip = self.tripTimeFrameLocationController.getTrip(withID: selectedTripID) else {
                return
            }
            
            self.tripTimeFrameLocationController.refreshSelected(trips: [trip])
        }
    }
        
}
