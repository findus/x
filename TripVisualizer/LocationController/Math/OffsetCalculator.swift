//
//  OffsetCalculator.swift
//  TripVisualizer
//
//  Created by Philipp Hentschel on 21.09.20.
//  Copyright © 2020 Philipp Hentschel. All rights reserved.
//

import Foundation

class OffsetCalculator {
    /**
     
     */
    private let ACCELERATION_TIME = 90.0
    private let TRAIN_ACCELERATION = 0.4
    private var tripLength = 14
    private var trip: TimeFrameTrip?
    
    /**
     Section Between 2 Stops
     */
    struct Section {
        // Lenth in Meters
        var length: Double
        // Duration in Seconds
        var duration: Double
    }

    /**
     This class tries to mimic an acceleration curve.
     At the moment it just assumes, that the train reaches vmax after 90 seconds, and brakes 90 seconds before the next stop.
     This might get a litte more accurate positions in real life, because with linear plotting, the train is always a little off because of its acceleration phase
     */
    public func getPositionForTime(_ time: Double, forSection section: Section) -> Double {
        
        if section.duration < 180 {
            return -1.0
        }
        
        if time > 0 && time <= ACCELERATION_TIME {
            //Train is in acceleration Phase
            
            // Acceleration per time formula
            return (0.5*TRAIN_ACCELERATION)*pow(time, 2)
        } else if time >= (section.duration - ACCELERATION_TIME) {
            //Train is in braking Phase
           
            return (0.5*(-TRAIN_ACCELERATION))*pow((time - section.duration), 2) + section.length
        } else {
            //Train is driving with vmax
            
            let halfTime = (section.duration/2)
            
            let startingPointY = getPositionForTime(ACCELERATION_TIME, forSection: section)
            let middleOfSection = halfTime*(section.length / section.duration)
            
            // f(x) mx+b
            let m = (middleOfSection - startingPointY) / (halfTime - ACCELERATION_TIME)
            let b = startingPointY - (m*ACCELERATION_TIME)
            
            //Position
            return (m*time)+b
            
        }
    }
}
