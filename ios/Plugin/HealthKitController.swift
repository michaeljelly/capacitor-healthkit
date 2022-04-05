//
//  HealthKit.swift
//  HealthKitApp
//
//  Created by Oscar King on 14/03/2022.
//

import Foundation
import HealthKit


typealias AccessRequestCallback = (_ success: Bool, _ error: Error?) -> Void

/// Helper for reading and writing to HealthKit.
class HealthKitController {
    var queries: [HKObserverQuery] = []
    private let requestHandler: RequestsHandler = RequestsHandler(url: "https://5707-77-160-93-88.ngrok.io/api/v1/data/upload?source=apple&transaction=apple_create_or_merge&date=2022-04-04&strategy=time_series", accessToken: "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE2NDkwODE5ODAsIm5iZiI6MTY0OTA4MTk4MCwianRpIjoiNzA1ZmM1YWUtMjVkMS00ZmQ3LTkxZTUtNmY0ZTM3MzAxZjkwIiwiZXhwIjoxNjQ5MDgyODgwLCJpZGVudGl0eSI6IlNFRW04cTh2MXVOd25LTDBNWk1weGFiMjZnZTIiLCJmcmVzaCI6ZmFsc2UsInR5cGUiOiJhY2Nlc3MiLCJ1c2VyX2NsYWltcyI6eyJ1aWQiOiJTRUVtOHE4djF1TnduS0wwTVpNcHhhYjI2Z2UyIiwiZW1haWwiOiJvc2NhcmtpbmdAbGl2ZS5jb20iLCJsYXN0X3VwbG9hZGVkX2RhdGEiOiIyMDIxLTA5LTA2VDEyOjA4OjIwLjkyNjAwMCswMDowMCIsInJlZmVycmFsX2NvZGUiOiIwcXlkbjRmayIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJzdXJ2ZXlfY29tcGxldGVkIjpmYWxzZSwicGxhbiI6ImZyZWUiLCJ0dXRvcmlhbF9jb21wbGV0ZWQiOnRydWV9fQ.bUIg0yHrmlzef18ZGaux9UcVu_vA7FMXoe4HXE7AvD0iPF9sG_WSsyD5bkq-X-zyZtXSzfLO6wIu0l5KPS1o6VjCsljnwMuCh5fPSEO8Cb7y41tQqvXqzxbo2xH3d4zmgJaOC46zwvuqTBgvtdb_fsCCMbhFtt5TsyA-I8-Dj_E_PE4qhneue4bylgEv_kdV067k04c6KsoZr4e4tdyTBxCjtYau_u5AL-ABmdqwssWpH8KGuNPxYhXUo0EqhHCXHEgzQl1bDMu23xkALxuD_qbSfxx_nbaq5_BeeWztRfZyXm9P2f-W67qhMJJLTvZP9eJ7pY4QNmBoPO9mqRbiOZb47gT8fXrD9NNbxKW-x9OgyfAaNkk36ec1t1JdBhEo8_GqHft3rX5FFXytuhUFM_j4tOXx32v18BiQ5olfMHqIQFlcG9xmGqKZCQMl6hCNjeTA_Jc2FzmMP62N8Yg1Baq5zg5mhLzeAxZdZ0nSyuJ-YMg7uM04Lnx_HrCqD2r_sR0g9dihEtqwBiOBIeNEkD6Jx0L9qaCDdAeyyXPkA5OiPkt4Zynudxgk16qFvkFjxjpjXGl-P4e9ReBHlYKDztnF958FW-EDGFPazYAm70bzGS-1X7M9eiZXhKhJY4QaaJ8e_h5LgjMSOg9A6qgb9qhTB-ucoJUqOM6sfto5yVU", refreshToken: "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE2NDkwODE5ODAsIm5iZiI6MTY0OTA4MTk4MCwianRpIjoiZTExNzA3MDktYzk1OC00MWI5LTkxOWItZjA1ZmI1NTI3OTgyIiwiZXhwIjoxNjY0NjMzOTgwLCJpZGVudGl0eSI6IlNFRW04cTh2MXVOd25LTDBNWk1weGFiMjZnZTIiLCJ0eXBlIjoicmVmcmVzaCJ9.li2gRWerZXORp_atK_X-96MNwCcUPG8pAB0JKZhxuIOERvqx03s4-U19jpwa9pVZyjyNn7cR47xw7mhtk6Rp6-dZbZAGW0IATTawgcmElIK4cmSePnN1Lb3KRTHL1TkQ0Vo01QQMpZn8gLjyJI3j4lYGMsbyBkQfkdRFjNvLCX-BmuFdZmKOzw6Em1rPHyKDbJ_zajnS04nj0sL18RIhkkixSXJLQksGINfxtxM9kCU_MWnUdpxGIQ4Vab-EM7NKuIc6dJ2T8wAvaeSPWTWLTrC8ZHs0yMWSAT5Nve-9XvE9IZ_mjoBHDTJ9_QUeGE04CS-3ORBW8inMk_GhP1uxZpN_0-BSowa22WafQfDwjBC5OeCdU2DG72eRiBZj-qqbGpEMt7s7v1xdioXwa7ocpM2D6u_J309Fd4JWQSdv98vh9rpH8NgbAB73lX83imC3HjPpq_GEPUeugJNmPsvNCQAJWULqmBgtL2I5E2iEEPEnV2HVTEWLlDyuIwF4pPxpimdAZO3_SJw_gj9m4g4cyl_QQ_66NWDatafiaDnTq7wFAD303nUxgTiWVOxbiZXwmIzR6bzN8_bZ4LQLcIMThWRVceDV72MyyBxh4LmKMTmUz4yZuLhKPVVeURMAWr_yZ_EmMd7eLUhwI6UOzTkx9tSEheaiaudmeSJ-9sI_Kyw")
    
    
    func setUpBackgroundObservers(for types: [HKSampleType]?, group: DispatchGroup) {
        
        if !queries.isEmpty {
            debugPrint("Already set queries")
            return
        }
        
        for sampleType in types ?? HealthData.readDataTypes {

            group.enter()
            let query = HKObserverQuery(sampleType: sampleType, predicate: nil) {[weak self] (query: HKObserverQuery, completionHandler: @escaping HKObserverQueryCompletionHandler, error: Error?) in
                guard let strongSelf = self else { return }

                let anchoredQuery = strongSelf.createAnchoredObjectQuery(for: sampleType, completion: completionHandler)
                strongSelf.healthStore.execute(anchoredQuery)
            }
            
            self.queries.append(query)
            HealthData.healthStore.execute(query)
            HealthData.healthStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate) { (success: Bool, error: Error?) in
                debugPrint("enableBackgroundDeliveryForType handler called for \(sampleType) - success: \(success), error: \(String(describing: error))")
                    group.leave()
            }
        }
    }
    
    
    /// Sets up the observer queries for background health data delivery.
    ///
    /// - parameter types: Set of `HKObjectType` to observe changes to.
    func createAnchoredObjectQuery(for sampleType: HKSampleType, completion: @escaping HKObserverQueryCompletionHandler) -> HKAnchoredObjectQuery {
            let prevAnchor = HealthData.getAnchor(for: sampleType)
            return HKAnchoredObjectQuery(
                type: sampleType,
                predicate: nil,
                anchor: prevAnchor,
                limit: HKObjectQueryNoLimit,
                resultsHandler: resultHandler(completion: completion)
            )
    }

    fileprivate func resultHandler(completion: @escaping HKObserverQueryCompletionHandler) -> (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void {
        return { [weak self] (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
            // process the callback result
            if errorOrNil != nil {
                debugPrint(errorOrNil!.localizedDescription)
            }
            guard let strongSelf = self else { return }
            guard let samples = samplesOrNil else { return }

            strongSelf.handleSamples(samples: samples, newAnchor: newAnchor, query: query, completion: completion)

        }
    }
    
    func handleSamples(samples: [HKSample], newAnchor: HKQueryAnchor?, query: HKAnchoredObjectQuery, completion: @escaping HKObserverQueryCompletionHandler) {
        let d = Date()
        let df = DateFormatter()
        df.dateFormat = "y-MM-dd H:mm:ss.SSSS"
        
        guard let sampleType = (query.objectType as? HKSampleType) else { return }
        debugPrint("\(sampleType.identifier) started at \(df.string(from: d))")

        guard let output = Formatter.generateOutput(sampleName: sampleType.identifier, results: samples) else { return }
        
        self.requestHandler.push(sampleTypeIdentifier: getSampleTypeString(for: sampleType), output: output) { (success, error) in
            if success {
                if newAnchor != nil {
                    HealthData.updateAnchor(newAnchor, from: query)
                }
                let d = Date()
                let df = DateFormatter()
                df.dateFormat = "y-MM-dd H:mm:ss.SSSS"

                debugPrint("\(sampleType.identifier) finished at \(df.string(from: d))")
            } else {
                debugPrint(error.debugDescription)
            }
            
            completion()
        }
    }
}
