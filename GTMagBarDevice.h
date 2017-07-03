//
//  GTMagBarDevice.h
//  MagBarSDK
//
//  Created by Don Messerli on 3/5/12.
//  Copyright (c) 2012 Griffin Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kOpticalScannerNone     0
#define kOpticalScanner1D       1
#define kOpticalScanner2D       2

#define kScanModeSingle         0
#define kScanModeMulti          1

// Components for failure report
#define kMagneticHead           1
#define kOpticalScanner         2

// Barcode types
enum barcode_types {
    BC_ALL = 0,                            // For enabling/disabling all supported barcode types
	
    // 1D Codes
    
    BC_UPC_A = 1,                           // UPC-A		
    BC_UPC_E = 2,                           // UPC-E
    BC_UPC_E1 = 3,                          // UPC-E1
    BC_EAN_8 = 4,                           // EAN-8/JAN-8
    BC_EAN_13 = 5,                          // EAN-13/JAN-12
    BC_BOOKLAND_EAN = 6,                    // Bookland EAN
    BC_UCC_COUPON_EXTENDED_CODE = 7,		// UCC Coupon Extended Code
    BC_ISSN_EAN = 8,                        // ISSN EAN
    BC_IATA = 9,                            // IATA
    BC_CODE_128 = 10,                       // Code 128
    BC_GS1_128 = 11,                        // GS1-128
    BC_CODABLOCK_F = 12,                    // Codablock F
    BC_ISBT_128 = 13,                       // ISBT 128
    BC_CODE_39 = 14,                        // Code 39
    BC_TRIOPTIC_CODE_39 = 15,               // Trioptic Code 39
    BC_CODE_32 = 16,                        // Code 32
    BC_CODE_93 = 17,                        // Code 93
    BC_CODE_11 = 18,                        // Code 11
    BC_INTERLEAVED_2OF5 = 19,               // Interleaved 2 of 5
    BC_DISCREET_2OF5 = 20,                  // Discrete 2 of 5
    BC_S_CODE = 21,                         // S-Code
    BC_CODABAR = 22,                        // Codabar
    BC_MSI = 23,                            // MSI
    BC_UK_PLESSEY = 24,                     // UK/Plessey
    BC_TELEPEN = 25,                        // Telepen
    BC_CHINESE_2OF5 = 26,                   // Chinese 2 of 5
    BC_MATRIX_2OF5 = 27,                    // Matrix 2 of 5
    BC_KOREAN_3OF5 = 28,                    // Korean 3 of 5
    BC_INVERSE_1D = 29,                     // Inverse 1D
    BC_GS1_DATABAR = 30,                    // GS1 Databar
    BC_GS1_DATABAR_LIMITED = 31,            // GS1 Databar Limited
    BC_GS1_DATABAR_EXPANDED = 32,           // GS1 Databar Expanded
    BC_COMPOSITE_CC_C = 33,                 // Composite CC-C
    BC_COMPOSITE_CC_AB = 34,                // Composite CC-A/B
    BC_COMPOSITE_TLC_39 = 35,               // Composite TLC-39
	
    // 2D Codes
    
    BC_PDF417 = 36,                         // PDF417
    BC_MICRO_PD_417 = 37,                   // MicroPDF417
    BC_DATA_MATRIX = 38,                    // Data Matrix
    BC_DATA_MATRIX_INVERSE = 39,            // Data Matrix Inverse
    BC_MAXICODE = 40,                       // Maxicode
    BC_QR_CODE = 41,                        // QR Code
    BC_MICRO_QR = 42,                       // MicroQR
    BC_AZTEC = 43,                          // Aztec
    
    // Postal Codes
    
    BC_US_POSTNET = 44,                     // US Postnet
    BC_US_PLANET = 45,                      // US Planet
    BC_UK_POSTAL = 46,                      // UK Postal
    BC_JAPAN_POSTAL = 47,                   // Japan Postal
    BC_AUSTRALIAN_POSTAL = 48,              // Australian Postal
    BC_NETHERLANDS_KIX_CODE = 49,           // Netherlands KIX Code
    BC_USPS_4CB = 50,                       // USPS 4CB/One Code/Intelligent Mail
    BC_UPU_FICS_POSTAL = 51,                // UPU FICS Postal
    
    BC_MAX_VALUE = 51
};

// Keys for NSDictionary passed to receivedMagneticStripeData:(NSDictionary*)data
#define kSwipeType          @"SwipeType"
#define kTrack1Clear        @"Track1Clear"
#define kTrack2Clear        @"Track2Clear"
#define kTrack3Clear        @"Track3Clear"
#define kTrack1Masked       @"Track1Masked"
#define kTrack2Masked       @"Track2Masked"
#define kTrack3Masked       @"Track3Masked"
#define kTrack1Encrypted    @"Track1Encrypted"
#define kTrack2Encrypted    @"Track2Encrypted"
#define kTrack3Encrypted    @"Track3Encrypted"
#define kEncryptionStatus   @"EncryptionStatus"
#define kSessionID          @"SessionID"
#define kKeySerialNumber    @"KeySerialNumber"   // DUKPT
#define kDeviceSerialNumber @"DeviceSerialNumber"
#define kCardholderName     @"CardholderName"
#define kCardIssuerIDNumber @"CardIssuerIDNumber"
#define kPANLast4Digits     @"PANLast4Digits"
#define kCardExpiration     @"CardExpiration"
#define kCardServiceCode    @"CardServiceCode"
#define kCardPANLength      @"CardPANLength"
#define kMagnePrint         @"MagnePrint"
#define kMagnePrintStatus   @"MagnePrintStatus"

// Possible values for kSwipeType
#define kEncryptedSwipe     @"Encrypted"
#define kClearSwipe         @"Clear"
#define kNonCreditCard      @"NonCreditCard"
#define kNotSupported       @"NotSupported" // i.e. Financial card in non-encrypted device

// Possible values returned by getCardReaderType
enum {
    UnknownCardReader = 0,
    MagtekCardReader = 1,
    IDTECHCardReader = 2
};


@class GTMagBarDevice;

@protocol GTMagBarDeviceDelegate <NSObject>
@required
- (void)magbarDevice:(GTMagBarDevice*)device accessoryConnected:(BOOL)state;
- (void)magbarDevice:(GTMagBarDevice*)device componentFailed:(int)components;
@optional
// bEnabled means charging the iDevice is enabled
// bCharging means the MagBarDevice is currently charging itself
- (void)magbarDevice:(GTMagBarDevice*)device receivedBatteryStatus:(BOOL)bEnabled charging:(BOOL)bCharging voltage:(NSInteger)volts;
- (void)magbarDevice:(GTMagBarDevice*)device receivedBarcodeData:(NSString*)data barcodeType:(NSInteger)barcodeType;
- (void)magbarDevice:(GTMagBarDevice*)device scanDidTimeout:(BOOL)bAlwaysYes;
- (void)magbarDevice:(GTMagBarDevice*)device scanStarted:(BOOL)bStarted;
- (void)magbarDevice:(GTMagBarDevice*)device cardReaderReady:(BOOL)bReady;
- (void)magbarDevice:(GTMagBarDevice*)device swipeStarted:(BOOL)bAlwaysYes;
- (void)magbarDevice:(GTMagBarDevice*)device receivedMagneticStripeData:(NSDictionary*)data;
- (void)magbarDevice:(GTMagBarDevice*)device receivedBadStripeData:(BOOL)bAlwaysYes;
- (void)magbarDevice:(GTMagBarDevice*)device ignoredSwipe:(BOOL)bAlwaysYes;
- (void)magbarDevice:(GTMagBarDevice*)device firmwareUpdateAvailable:(NSString*)newVersion fromVersion:(NSString*)currentVersion;
- (void)magbarDevice:(GTMagBarDevice*)device physicalButtonPressed:(BOOL)bAlwaysYes;
- (void)magbarDevice:(GTMagBarDevice*)device physicalButtonReleased:(BOOL)bAlwaysYes;

@end

@interface GTMagBarDevice : NSObject {
    BOOL accessoryAttached;
    
    id<GTMagBarDeviceDelegate> delegate;
}

+ (GTMagBarDevice *)sharedDevice;
- (NSString*)getSDKVersion;
- (NSString*)getScannerManufacturer;
- (NSString*)getScannerFirmwareRevision;    // Firmware revision of barcode scanner module
- (NSString*)getSerialNumber;
- (NSString*)getFirmwareVersion;            // Firmware version of Griffin device
- (NSString*)getModelNumber;                // Model number of Griffin device
- (NSInteger)getCardReaderType;             // MagTek, IDTech, etc.

- (NSArray*)getSupportedBarcodeTypes;
- (NSArray*)getEnabledBarcodeTypes;
- (NSString*)stringForBarcodeType:(NSInteger)barcodeType;
- (BOOL)getBarcodeSupported:(NSInteger)barcodeType;
- (BOOL)getBarcodeEnabled:(NSInteger)barcodeType;
- (void)setBarcodeEnabled:(NSInteger)barcodeType enabled:(BOOL)bEnabled;

- (NSInteger)getTimeout;
- (void)setTimeout:(NSInteger)timeout;

- (NSInteger)getScanMode;
- (void)setScanMode:(NSInteger)mode;

- (BOOL)getScannerEnabled;
- (void)setScannerEnabled:(BOOL)bEnabled;

- (BOOL)getSuppressNoScanResponse;
- (void)setSuppressNoScanResponse:(BOOL)bSuppress;

- (void)startScan;
- (void)startScanWithLeadingTargetTime:(NSInteger)time;    // time is in 100 millisecond increments.  Max is 5 seconds.
- (void)abortScan;

- (void)setMagCardEnabled:(BOOL)bEnabled;   // Only used for Kiosk Retail hardware. Olli hardware keeps the MagCard reader enabled at all times.
- (BOOL)getMagCardEnabled;  // Only used for Kiosk Retail hardware. Olli hardware keeps the MagCard reader enabled at all times.
- (void)isMagCardReaderReady;           // Returns answer via cardReaderReady:(BOOL)bReady delegate method

- (void)setMagCardAutoDisabled:(BOOL)bEnabled;  // Only used for Kiosk Retail hardware. Olli hardware keeps the MagCard reader enabled at all times.
- (BOOL)getMagCardAutoDisabled; // Only used for Kiosk Retail hardware. Olli hardware keeps the MagCard reader enabled at all times.

- (void)setChargingEnabled:(BOOL)bEnabled;
- (void)getBatteryStatus;

- (NSInteger)getCardReaderDormantTime;
- (void)setCardReaderDormantTime:(NSInteger)time;       // time is in seconds. Default is 5 seconds.

// IDTECH magnetic read head commands
- (void)idtechSetNumberOfLeadingPANClearDigits:(NSInteger)numberOfLeadingPANClearDigits;
- (void)idtechSetNumberOfTrailingPANClearDigits:(NSInteger)numberOfTrailingPANClearDigits;
- (void)idtechSetMaskCharacter:(NSString *)maskCharacter;
- (void)idtechSetExpirationDateClear:(BOOL)shouldBeClear;

// Physical pushbutton
- (BOOL)hasPhysicalPushbutton;
- (BOOL)getButtonEnabled;
- (void)setButtonEnabled:(BOOL)bEnabled;

// Firmware update
- (BOOL)isGriffinMagBarAppInstalled;
- (BOOL)launchGriffinMagBarApp:(BOOL)bShowInAppStoreIfNotInstalled;
- (void)showGriffinMagBarAppInAppStore;

@property (nonatomic, readonly) BOOL accessoryAttached;
@property (nonatomic, assign) id<GTMagBarDeviceDelegate> delegate;
@end


