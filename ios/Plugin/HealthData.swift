/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A collection of HealthKit properties, functions, and utilities.
*/

import Foundation
import HealthKit

class HealthData {
    
    static let healthStore: HKHealthStore = HKHealthStore()
    
    // MARK: - Data Types
    
    static var readDataTypes: [HKSampleType] {
        return allHealthDataTypes
    }
    
    static var shareDataTypes: [HKSampleType] {
        return allHealthDataTypes
    }
    
    private static var allHealthDataTypes: [HKSampleType] {
        let typeIdentifiers = [
            "distanceWalkingRunning",
            "height",
            "bodyMass",
            "flightsClimbed"
        ]
        
        return typeIdentifiers.compactMap { getSampleType(for: $0) }
    }
    
    func getTypes(items: [String]) -> Set<HKSampleType> {
        var types: Set<HKSampleType> = []
        for item in items {
            switch item {
            case "steps":
                types.insert(HKQuantityType.quantityType(forIdentifier: .stepCount)!)
            case "stairs":
                types.insert(HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!)
            case "duration":
                types.insert(HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!)
            case "activity":
                types.insert(HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!)
                types.insert(HKWorkoutType.workoutType())
            case "calories":
                types.insert(HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!)
                types.insert(HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!)
            case "distance":
                types.insert(HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!)
                types.insert(HKQuantityType.quantityType(forIdentifier: .distanceCycling)!)
            case "bloodGlucose":
                types.insert(HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!)
            case "heartRate":
                types.insert(HKQuantityType.quantityType(forIdentifier: .heartRate)!)
                types.insert(HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!)
                types.insert(HKQuantityType.quantityType(forIdentifier: .walkingHeartRateAverage)!)
                types.insert(HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!)
            case "oxygenSaturation":
                types.insert(HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!)
            case "bodyTemperature":
                types.insert(HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!)
            case "bloodPressure":
                types.insert(HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!)
                types.insert(HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!)
            case "respiratoryRate":
                types.insert(HKQuantityType.quantityType(forIdentifier: .respiratoryRate)!)
            default:
                print("no match in case: " + item)
            }
        }
        return types
    }
    // MARK: - Authorization
    
    /// Request health data from HealthKit if needed, using the data types within `HealthData.allHealthDataTypes`
    class func requestHealthDataAccessIfNeeded(dataTypes: [String]? = nil, completion: @escaping (_ success: Bool) -> Void) {
        var readDataTypes = Set(allHealthDataTypes)
        var shareDataTypes = Set(allHealthDataTypes)
        
        if let dataTypeIdentifiers = dataTypes {
            readDataTypes = Set(dataTypeIdentifiers.compactMap { getSampleType(for: $0) })
            shareDataTypes = readDataTypes
        }
        
        requestHealthDataAccessIfNeeded(toShare: shareDataTypes, read: readDataTypes, completion: completion)
    }
    
    /// Request health data from HealthKit if needed.
    class func requestHealthDataAccessIfNeeded(toShare shareTypes: Set<HKSampleType>?,
                                               read readTypes: Set<HKObjectType>?,
                                               completion: @escaping (_ success: Bool) -> Void) {
        if !HKHealthStore.isHealthDataAvailable() {
            fatalError("Health data is not available!")
        }
        
        print("Requesting HealthKit authorization...")
        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { (success, error) in
            if let error = error {
                print("requestAuthorization error:", error.localizedDescription)
            }
            
            if success {
                print("HealthKit authorization request was successful!")
            } else {
                print("HealthKit authorization was not successful.")
            }
            
            completion(success)
        }
    }
        
    // MARK: - Helper Functions
    
    class func updateAnchor(_ newAnchor: HKQueryAnchor?, from query: HKAnchoredObjectQuery) {
        if let sampleType = query.objectType as? HKSampleType {
            setAnchor(newAnchor, for: sampleType)
        } else {
            if let identifier = query.objectType?.identifier {
                print("anchoredObjectQueryDidUpdate error: Did not save anchor for \(identifier) – Not an HKSampleType.")
            } else {
                print("anchoredObjectQueryDidUpdate error: query doesn't not have non-nil objectType.")
            }
        }
    }
    
    private static let userDefaults = UserDefaults.standard
    
    private static let anchorKeyPrefix = "Anchor_"
    
    private class func anchorKey(for type: HKSampleType) -> String {
        return anchorKeyPrefix + type.identifier
    }
    
    /// Returns the saved anchor used in a long-running anchored object query for a particular sample type.
    /// Returns nil if a query has never been run.
    class func getAnchor(for type: HKSampleType) -> HKQueryAnchor? {
        if let anchorData = userDefaults.object(forKey: anchorKey(for: type)) as? Data {
            return try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: anchorData)
        }
        
        return nil
    }
    
    /// Update the saved anchor used in a long-running anchored object query for a particular sample type.
    private class func setAnchor(_ queryAnchor: HKQueryAnchor?, for type: HKSampleType) {
        if let queryAnchor = queryAnchor,
            let data = try? NSKeyedArchiver.archivedData(withRootObject: queryAnchor, requiringSecureCoding: true) {
            userDefaults.set(data, forKey: anchorKey(for: type))
        }
    }
}
