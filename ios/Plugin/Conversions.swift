
// MARK: Sample Type Identifier Support

/// Return an HKSampleType based on the input identifier that corresponds to an HKQuantityTypeIdentifier, HKCategoryTypeIdentifier
/// or other valid HealthKit identifier. Returns nil otherwise.

func getSampleType(for sampleName: String) -> HKSampleType? {
    switch sampleName {
    case "stepCount":
        return HKQuantityType.quantityType(forIdentifier: .stepCount)
    case "height":
        return HKQuantityType.quantityType(forIdentifier: .height)
    case "bodyMass":
        return HKQuantityType.quantityType(forIdentifier: .bodyMass)
    case "flightsClimbed":
        return HKQuantityType.quantityType(forIdentifier: .flightsClimbed)
    case "appleExerciseTime":
        return HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)
    case "activeEnergyBurned":
        return HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
    case "basalEnergyBurned":
        return HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)
    case "distanceWalkingRunning":
        return HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
    case "distanceCycling":
        return HKQuantityType.quantityType(forIdentifier: .distanceCycling)
    case "bloodGlucose":
        return HKQuantityType.quantityType(forIdentifier: .bloodGlucose)
    case "oxygenSaturation":
        return HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)
    case "bodyTemperature":
        return HKQuantityType.quantityType(forIdentifier: .bodyTemperature)
    case "bloodPressureDiastolic":
        return HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)
    case "bloodPressureSystolic":
        return HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)
    case "respiratoryRate":
        return HKQuantityType.quantityType(forIdentifier: .respiratoryRate)
    case "heartRate":
        return HKQuantityType.quantityType(forIdentifier: .heartRate)
    case "restingHeartRate":
        return HKQuantityType.quantityType(forIdentifier: .restingHeartRate)
    case "walkingHeartRateAverage":
        return HKQuantityType.quantityType(forIdentifier: .walkingHeartRateAverage)
    case "heartRateVariabilitySDNN":
        return HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
    case "sleepAnalysis":
        return HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
    case "workoutType":
        return HKWorkoutType.workoutType()
    default:
        return nil
    }
}


func getSampleTypeString(for sample: HKSampleType) -> String {
    switch sample {
    case is HKQuantityType:
        let temp = sample.identifier.deletingPrefix("HKQuantityTypeIdentifier")
        return temp.replacingCharacters(in: ...temp.startIndex, with: temp.first!.lowercased())
    case is HKCategoryType:
        let temp = sample.identifier.deletingPrefix("HKCategoryTypeIdentifier")
        return temp.replacingCharacters(in: ...temp.startIndex, with: temp.first!.lowercased())
    case is HKWorkoutType:
        return "workoutType"
    default:
        return sample.identifier
    }
}

//MARK: String Conversions

extension String {
    func titleCase() -> String {
        return self
            .replacingOccurrences(of: "([A-Z])",
                                  with: " $1",
                                  options: .regularExpression,
                                  range: range(of: self))
            .replacingOccurrences(of: "And",
                                  with: "and",
                                  options: .regularExpression,
                                  range: range(of: self)
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized // If input is in llamaCase
    }

    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}