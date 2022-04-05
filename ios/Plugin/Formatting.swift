//
//  Formatter.swift
//  HealthKitSync
//
//  Created by Oscar King on 01/04/2022.
//

import Foundation
import HealthKit

class Formatter {
    class func getUnit(_ sample: HKQuantitySample) -> HKUnit? {
        let unit: HKUnit?
        let quantityType = sample.quantityType

        if quantityType.is(compatibleWith: HKUnit.meter()) {
            unit = HKUnit.meter()
        } else if quantityType.is(compatibleWith: HKUnit.count()) {
            unit = HKUnit.count()
        } else if quantityType.is(compatibleWith: HKUnit.count().unitDivided(by: HKUnit.minute())) {
            unit = HKUnit.count().unitDivided(by: HKUnit.minute())
        } else if quantityType.is(compatibleWith: HKUnit.secondUnit(with: .milli)) {
            unit = HKUnit.secondUnit(with: .milli)
        } else if quantityType.is(compatibleWith: HKUnit.percent()) {
            unit = HKUnit.percent()
        } else if quantityType.is(compatibleWith: HKUnit.degreeCelsius()) {
            unit = HKUnit.degreeCelsius()
        } else if quantityType.is(compatibleWith: HKUnit.millimeterOfMercury()) {
            unit = HKUnit.millimeterOfMercury()
        } else if quantityType.is(compatibleWith: HKUnit.minute()) {
            unit = HKUnit.minute()
        } else if quantityType.is(compatibleWith: HKUnit.kilocalorie()) {
            unit = HKUnit.kilocalorie()
        } else if quantityType.is(compatibleWith: HKUnit.gramUnit(with: .kilo)) {
            unit = HKUnit.gramUnit(with: .kilo)
        } else if quantityType.is(compatibleWith: HKUnit.moleUnit(withMolarMass: HKUnitMolarMassBloodGlucose).unitDivided(by: HKUnit.literUnit(with: .kilo))) {
            unit = HKUnit.moleUnit(withMolarMass: HKUnitMolarMassBloodGlucose).unitDivided(by: HKUnit.literUnit(with: .kilo))
        } else {
            print("Error: unknown unit type")
            unit = nil
        }
        
        return unit
    }
    
    class func getUnit(_ sample: HKWorkout) -> HKUnit? {
        if (sample.totalDistance?.is(compatibleWith: HKUnit.meter()))! {
            return HKUnit.meter()
        } else if (sample.totalFlightsClimbed?.is(compatibleWith: HKUnit.count()))! {
            return HKUnit.count()
        } else if (sample.totalEnergyBurned?.is(compatibleWith: HKUnit.kilocalorie()))! {
            return HKUnit.kilocalorie()
        } else if (sample.totalSwimmingStrokeCount?.is(compatibleWith: HKUnit.count()))! {
            return HKUnit.count()
        } else {
            return nil
        }
    }
    
    class func generateOutput(sampleName: String, results: [HKSample]?) -> Output? {
            var output: [OutputItem] = []
            if results != nil {
                for result in results! {
                    if sampleName == "sleepAnalysis" {
                        guard let sample = result as? HKCategorySample else {
                            return nil
                        }
                        
                        output.append(SleepAnalysisOutput.from(sample: sample))
                    } else if sampleName == "workoutType" {
                        guard let sample = result as? HKWorkout else {
                            return nil
                        }
                        
                        guard let constructed_sample = WorkoutTypeOutput.from(sample: sample) else {continue}
                        output.append(constructed_sample)
                    } else {
                        guard let sample = result as? HKQuantitySample else {
                            return nil
                        }
                        
                        output.append(StandardOutput.from(sample: sample))
                    }
                }
            }
        
            return Output(countReturn: output.count, resultData: output)
        }
    
    class func getTimeZoneString(sample: HKSample? = nil, shouldReturnDefaultTimeZoneInExceptions _: Bool = true) -> String {
            var timeZone: TimeZone?
            if let metaDataTimeZoneValue = sample?.metadata?[HKMetadataKeyTimeZone] as? String {
                timeZone = TimeZone(identifier: metaDataTimeZoneValue)
            }
            if timeZone == nil {
                timeZone = TimeZone.current
            }
            let seconds: Int = timeZone?.secondsFromGMT() ?? 0
            let hours = seconds / 3600
            let minutes = abs(seconds / 60) % 60
            let timeZoneString = String(format: "%+.2d:%.2d", hours, minutes)
            return timeZoneString
        }
}
