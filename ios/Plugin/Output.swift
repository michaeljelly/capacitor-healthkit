//
//  Output.swift
//  HealthSync
//
//  Created by Oscar King on 24/03/2022.
//

import Foundation
import HealthKit

class Output: Encodable, CustomStringConvertible {
    let countReturn: Int
    let resultData: [OutputItem]
    
    init(countReturn: Int, resultData: [OutputItem]) {
        self.countReturn = countReturn
        self.resultData = resultData
    }
    
    var description: String {
            return "Output {countReturn: \(countReturn), resultData: \(resultData)}"
        }
}

class OutputItem: Encodable, CustomStringConvertible {
    var uuid: String
    var startDate: String
    var endDate: String
    var source: String
    var sourceBundleId: String
    var duration: Double
    
    init(uuid: String, startDate: String, endDate: String, source: String, sourceBundleId: String, duration: Double) {
        self.uuid = uuid
        self.startDate = startDate
        self.endDate = endDate
        self.source = source
        self.sourceBundleId = sourceBundleId
        self.duration = duration
    }
    
    private enum CodingKeys : String, CodingKey {
        case uuid
        case startDate
        case endDate
        case source
        case sourceBundleId
        case duration
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(source, forKey: .source)
        try container.encode(sourceBundleId, forKey: .sourceBundleId)
        try container.encode(duration, forKey: .duration)
    }
    
    var description: String {
            return "OutputItem {uuid: \(uuid),startDate: \(startDate),endDate: \(endDate),source: \(source),sourceBundleId: \(sourceBundleId),duration: \(duration)}"
        }
}

class SleepAnalysisOutput: OutputItem {
    
    var timeZone: String
    var sleepState: String
    
    init(uuid: String, startDate: String, endDate: String, source: String, sourceBundleId: String, duration: Double, timeZone: String, sleepState: String) {
        self.timeZone = timeZone
        self.sleepState = sleepState
        
        super.init(uuid: uuid, startDate: startDate, endDate: endDate, source: source, sourceBundleId: sourceBundleId, duration: duration)
    }
    
    private enum CodingKeys : String, CodingKey {
        case timeZone
        case sleepState
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timeZone, forKey: .timeZone)
        try container.encode(sleepState, forKey: .sleepState)
    }
    
    class func from(sample: HKCategorySample) -> OutputItem {
        let sleepSD = sample.startDate as NSDate
        let sleepED = sample.endDate as NSDate
        let sleepInterval = sleepED.timeIntervalSince(sleepSD as Date)
        let sleepHoursBetweenDates = sleepInterval / 3600
        let sleepState = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
        
        return SleepAnalysisOutput(
            uuid: sample.uuid.uuidString,
            startDate: ISO8601DateFormatter().string(from: sample.startDate),
            endDate: ISO8601DateFormatter().string(from: sample.endDate),
            source: sample.sourceRevision.source.name,
            sourceBundleId: sample.sourceRevision.source.bundleIdentifier,
            duration: sleepHoursBetweenDates,
            timeZone: Formatter.getTimeZoneString(sample: sample) as String,
            sleepState: sleepState
        )
    }
    
    override var description: String {
            return "SleepAnalysisOutputItem {uuid: \(uuid),startDate: \(startDate),endDate: \(endDate),source: \(source),sourceBundleId: \(sourceBundleId),duration: \(duration),timeZone: \(timeZone),sleepState: \(sleepState)}"
        }
}

class WorkoutTypeOutput: OutputItem {
    var workoutActivityId: UInt
    var workoutActivityName: String
    var totalEnergyBurned: Double
    var totalDistance: Double
    var totalFlightsClimbed: Double
    var totalSwimmingStrokeCount: Double
    
    init(
        uuid: String,
        startDate: String,
        endDate: String,
        source: String,
        sourceBundleId: String,
        duration: Double,
        workoutActivityId: UInt,
        workoutActivityName: String,
        totalEnergyBurned: Double,
        totalDistance: Double,
        totalFlightsClimbed: Double,
        totalSwimmingStrokeCount: Double
    ) {
        self.workoutActivityId = workoutActivityId
        self.workoutActivityName = workoutActivityName
        self.totalEnergyBurned = totalEnergyBurned
        self.totalDistance = totalDistance
        self.totalFlightsClimbed = totalFlightsClimbed
        self.totalSwimmingStrokeCount = totalSwimmingStrokeCount
        
        super.init(uuid: uuid, startDate: startDate, endDate: endDate, source: source, sourceBundleId: sourceBundleId, duration: duration)
    }
    
    private enum CodingKeys : String, CodingKey {
        case workoutActivityId
        case workoutActivityName
        case totalEnergyBurned
        case totalDistance
        case totalFlightsClimbed
        case totalSwimmingStrokeCount
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(workoutActivityId, forKey: .workoutActivityId)
        try container.encode(workoutActivityName, forKey: .workoutActivityName)
        try container.encode(totalEnergyBurned, forKey: .totalEnergyBurned)
        try container.encode(totalDistance, forKey: .totalDistance)
        try container.encode(totalFlightsClimbed, forKey: .totalFlightsClimbed)
        try container.encode(totalSwimmingStrokeCount, forKey: .totalSwimmingStrokeCount)
    }
    
    class func from(sample: HKWorkout) -> WorkoutTypeOutput? {
        guard let unit = Formatter.getUnit(sample) else { return nil}
    
        let TEBData: Double = sample.totalEnergyBurned?.doubleValue(for: unit) ?? -1
        let TDData: Double = sample.totalDistance?.doubleValue(for: unit) ?? -1
        let TFCData: Double = sample.totalFlightsClimbed?.doubleValue(for: unit) ?? -1
        let TSSCData: Double = sample.totalSwimmingStrokeCount?.doubleValue(for: unit) ?? -1
        
        let workoutSD = sample.startDate as NSDate
        let workoutED = sample.endDate as NSDate
        let workoutInterval = workoutED.timeIntervalSince(workoutSD as Date)
        let workoutHoursBetweenDates = workoutInterval / 3600
        return WorkoutTypeOutput(
            uuid: sample.uuid.uuidString,
            startDate: ISO8601DateFormatter().string(from: sample.startDate),
            endDate: ISO8601DateFormatter().string(from: sample.endDate),
            source: sample.sourceRevision.source.name,
            sourceBundleId: sample.sourceRevision.source.bundleIdentifier,
            duration: workoutHoursBetweenDates,
            workoutActivityId: sample.workoutActivityType.rawValue,
            workoutActivityName: sample.workoutActivityType.rawValue.description.titleCase(),
            totalEnergyBurned: TEBData,
            totalDistance: TDData,
            totalFlightsClimbed: TFCData,
            totalSwimmingStrokeCount: TSSCData
        )
    }
    
    override var description: String {
            return "WorkoutTypeOutputItem {uuid: \(uuid),startDate: \(startDate),endDate: \(endDate),source: \(source),sourceBundleId: \(sourceBundleId),duration: \(duration),workoutActivityId: \(workoutActivityId),workoutActivityName: \(workoutActivityName),totalEnergyBurned: \(totalEnergyBurned),totalDistance: \(totalDistance),totalFlightsClimbed: \(totalFlightsClimbed),totalSwimmingStrokeCount: \(totalSwimmingStrokeCount)}"
        }
}

class StandardOutput: OutputItem {
    let unitName: String
    let value: Double
    
    init(uuid: String, startDate: String, endDate: String, source: String, sourceBundleId: String, duration: Double, unitName: String, value: Double) {
        self.unitName = unitName
        self.value = value
        
        super.init(uuid: uuid, startDate: startDate, endDate: endDate, source: source, sourceBundleId: sourceBundleId, duration: duration)
    }
    
    private enum CodingKeys : String, CodingKey {
        case unitName
        case value
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(unitName, forKey: .unitName)
        try container.encode(value, forKey: .value)
    }
    
    class func from(sample: HKQuantitySample) -> StandardOutput {
        let unit: HKUnit? = Formatter.getUnit(sample)

        let quantitySD: NSDate
        let quantityED: NSDate
        quantitySD = sample.startDate as NSDate
        quantityED = sample.endDate as NSDate
        let quantityInterval = quantityED.timeIntervalSince(quantitySD as Date)
        let quantitySecondsInAnHour: Double = 3600
        let quantityHoursBetweenDates = quantityInterval / quantitySecondsInAnHour
        return StandardOutput(
            uuid: sample.uuid.uuidString,
            startDate: ISO8601DateFormatter().string(from: sample.startDate),
            endDate: ISO8601DateFormatter().string(from: sample.endDate),
            source: sample.sourceRevision.source.name,
            sourceBundleId: sample.sourceRevision.source.bundleIdentifier,
            duration: quantityHoursBetweenDates,
            unitName: unit?.unitString ?? sample.quantityType.identifier.description,
            value: sample.quantity.doubleValue(for: unit!)
        )
    }
    
    override var description: String {
            return "StandardOutputItem {uuid: \(uuid),startDate: \(startDate),endDate: \(endDate),source: \(source),sourceBundleId: \(sourceBundleId),duration: \(duration),unitName: \(unitName),value: \(value)}"
        }
}
