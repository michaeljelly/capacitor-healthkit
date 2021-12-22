#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>
#import <Capacitor/CAPBridgedJSTypes.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(CapacitorHealthkit, "CapacitorHealthkit",
           CAP_PLUGIN_METHOD(requestAuthorization, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(isAvailable, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(queryHKitSampleType, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(multipleQueryHKitSampleType, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(queryHKitStatisticsCollection, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(isEditionAuthorized, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(multipleIsEditionAuthorized, CAPPluginReturnPromise);
           )