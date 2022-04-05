import Capacitor
import HealthKit

var healthStore = HKHealthStore()

@objc(CapacitorHealthkit)
public class CapacitorHealthkit: CAPPlugin {
    private let healthKitController = HealthKitController()

    @objc func isAvailable(_ call: CAPPluginCall) {
        if HKHealthStore.isHealthDataAvailable() {
            return call.resolve()
        } else {
            return call.reject("Health data not available")
        }
    }

    @objc func isEditionAuthorized(_ call: CAPPluginCall) {
        guard let sampleName = call.options["sampleName"] as? String else {
            return call.reject("Must provide sampleName")
        }

        let sampleType: HKSampleType? = getSampleType(sampleName: sampleName)
        if sampleType == nil {
            return call.reject("Cannot match sample name")
        }

        if healthStore.authorizationStatus(for: sampleType!) == .sharingAuthorized {
            return call.resolve()
        } else {
            return call.reject("Permission Denied to Access data")
        }
    }

    @objc func multipleIsEditionAuthorized(_ call: CAPPluginCall) {
        guard let sampleNames = call.options["sampleNames"] as? [String] else {
            return call.reject("Must provide sampleNames")
        }

        for sampleName in sampleNames {
            guard let sampleType: HKSampleType = getSampleType(sampleName: sampleName) else {
                return call.reject("Cannot match sample name")
            }
            if healthStore.authorizationStatus(for: sampleType) != .sharingAuthorized {
                return call.reject("Permission Denied to Access data")
            }
        }
        return call.resolve()
    }

    @objc func requestAuthorization(_ call: CAPPluginCall) {
        guard let _all = call.options["all"] as? [String] else {
            return call.reject("Must provide all")
        }
        guard let _read = call.options["read"] as? [String] else {
            return call.reject("Must provide read")
        }
        guard let _write = call.options["write"] as? [String] else {
            return call.reject("Must provide write")
        }

        let writeTypes: Set<HKSampleType> = HealthData.getTypes(items: _write).union(HealthData.getTypes(items: _all))
        let readTypes: Set<HKSampleType> = HealthData.getTypes(items: _read).union(HealthData.getTypes(items: _all))

        HealthData.requestHealthDataAccessIfNeeded(toShare: writeTypes, read: readTypes) { success, _ in
            if !success {
                call.reject("Could not get permission")
                return
            }
            call.resolve()
        }
    }

    @objc func setUpBackgroundObservers(_ call: CAPPluginCall) {
        guard let _sampleNames = call.options["sampleNames"] as? [String] else {
            call.reject("Must provide sampleNames")
            return
        }

        let sampleTypes: [HKSampleType] = _sampleNames.compactMap { getSampleType(for: $0) }
        let group = DispatchGroup()

        healthKitController.setUpBackgroundObservers(for: sampleTypes)

        group.notify(queue: .main) {
            call.resolve()
        }
    }

    @objc func queryHKitSampleType(_ call: CAPPluginCall) {
        guard let _sampleName = call.options["sampleName"] as? String else {
            return call.reject("Must provide sampleName")
        }
        guard let _startDate = ISO8601DateFormatter().date(from: call.options["startDate"] as! String) else {
            print("queryHKitSampleType", call.options["startDate"]!, _sampleName)
            return call.reject("Must provide startDate as ISOString without milliseconds: queryHKitSampleType")
        }
        guard let _endDate = ISO8601DateFormatter().date(from: call.options["endDate"] as! String) else {
            return call.reject("Must provide endDate as ISOString without milliseconds")
        }
        guard let _limit = call.options["limit"] as? Int else {
            return call.reject("Must provide limit")
        }

        let limit: Int = (_limit == 0) ? HKObjectQueryNoLimit : _limit

        let predicate = HKQuery.predicateForSamples(withStart: _startDate, end: _endDate, options: HKQueryOptions.strictStartDate)

        guard let sampleType: HKSampleType = getSampleType(sampleName: _sampleName) else {
            return call.reject("Error in sample name")
        }

        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: limit, sortDescriptors: nil) {
            _, results, _ in
            guard let output = Formatter.generateOutput(sampleName: _sampleName, results: results) else { 
                return call.reject("Error happened while generating outputs")
            }

            call.resolve([
                "countReturn": output.countReturn,
                "resultData": output.resultData,
            ])
        }
        healthStore.execute(query)
    }

    @objc func multipleQueryHKitSampleType(_ call: CAPPluginCall) {
        guard let _sampleNames = call.options["sampleNames"] as? [String] else {
            call.reject("Must provide sampleNames")
            return
        }
        guard let _startDate = ISO8601DateFormatter().date(from: call.options["startDate"] as! String) else {
            print("multipleQueryHKitSampleType", call.options["startDate"]!)
            call.reject("Must provide startDate as ISOString without milliseconds: multipleQueryHKitSampleType")
            return
        }
        guard let _endDate = ISO8601DateFormatter().date(from: call.options["endDate"] as! String) else {
            call.reject("Must provide endDate as ISOString without milliseconds")
            return
        }
        guard let _limit = call.options["limit"] as? Int else {
            call.reject("Must provide limit")
            return
        }

        let limit: Int = (_limit == 0) ? HKObjectQueryNoLimit : _limit

        var output: [String: [String: Any]] = [:]

        let dispatchGroup = DispatchGroup()

        for _sampleName in _sampleNames {
            dispatchGroup.enter()

            queryHKitSampleTypeSpecial(sampleName: _sampleName, startDate: _startDate, endDate: _endDate, limit: limit) { result in
                switch result {
                case let .success(sampleOutput):
                    output[_sampleName] = sampleOutput
                case let .failure(error):

                    var errorMessage = ""
                    if let localError = error as? HKSampleError {
                        errorMessage = localError.outputMessage
                    } else {
                        errorMessage = error.localizedDescription
                    }
                    output[_sampleName] = ["errorDescription": errorMessage]
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            print(output.description)
            call.resolve(output)
        }
    }

    @objc func queryHKitStatisticsCollection(_ call: CAPPluginCall) {
        guard let _sampleName = call.options["sampleName"] as? String else {
            return call.reject("Must provide sampleName")
        }
        guard let _startDate = ISO8601DateFormatter().date(from: call.options["startDate"] as! String) else {
            print("queryHKitStatisticsCollection", call.options["startDate"]!, _sampleName)

            return call.reject("Must provide startDate as ISOString without milliseconds: queryHKitStatisticsCollection")
        }
        guard let _endDate = ISO8601DateFormatter().date(from: call.options["endDate"] as! String) else {
            return call.reject("Must provide endDate as ISOString without milliseconds")
        }

        var interval = DateComponents()
        interval.day = call.options["interval"] as? Int ?? 1

        //   Get the start of the day
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let startDateDayStart = cal.startOfDay(for: _startDate)

        let predicate = HKQuery.predicateForSamples(withStart: _startDate, end: _endDate, options: HKQueryOptions.strictStartDate)

        guard let sampleType: HKSampleType = getSampleType(sampleName: _sampleName) else {
            return call.reject("Error in sample name")
        }

        //  Perform the Query
        let query = HKStatisticsCollectionQuery(
            quantityType: sampleType as! HKQuantityType,
            quantitySamplePredicate: predicate,
            options: [.cumulativeSum],
            anchorDate: startDateDayStart as Date,
            intervalComponents: interval
        )

        query.initialResultsHandler = { _, results, error in
            if error != nil {
                print("Something went Wrong")
                return
            }
            var output: [[String: Any]] = []
            for sample in results?.statistics() ?? [] {
                let periodSum: Double! = sample.sumQuantity()?.doubleValue(for: HKUnit.count())

                let constructedSample: [String: Any] = [
                    "startDate": ISO8601DateFormatter().string(from: sample.startDate),
                    "endDate": ISO8601DateFormatter().string(from: sample.endDate),
                    "value": Int(periodSum!),
                ]
                output.append(constructedSample)
            }
            print(output)
            call.resolve([
                "resultData": output,
            ])
        }

        healthStore.execute(query)
    }

    func queryHKitSampleTypeSpecial(sampleName: String, startDate: Date, endDate: Date, limit: Int, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictStartDate)

        guard let sampleType: HKSampleType = getSampleType(sampleName: sampleName) else {
            return completion(.failure(HKSampleError.sampleTypeFailed))
        }

        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: limit, sortDescriptors: nil) {
            _, results, _ in
            guard let output = Formatter.generateOutput(sampleName: sampleName, results: results) else {
                return completion(.failure(HKSampleError.sampleTypeFailed))
            }
            completion(.success([
                "countReturn": output.countReturn,
                "resultData": output.resultData,
            ]))
        }
        healthStore.execute(query)
    }
}
