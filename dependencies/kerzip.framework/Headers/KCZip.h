

#ifndef _KCZIPARCHIVE_H
#define _KCZIPARCHIVE_H

#import <Foundation/Foundation.h>

@interface KCZip : NSObject

#pragma mark - zip
// Zip
// without password
+ (BOOL)createZip:(NSString *)path withPaths:(NSArray *)paths;
+ (BOOL)createZip:(NSString *)path withDir:(NSString *)directoryPath;

+ (BOOL)createZip:(NSString *)path withDir:(NSString *)directoryPath keepParentDir:(BOOL)keepParentDirectory;

// with password, password could be nil
+ (BOOL)createZip:(NSString *)path withPaths:(NSArray *)paths withPassword:(NSString *)password;
+ (BOOL)createZip:(NSString *)path withDir:(NSString *)directoryPath withPassword:(NSString *)password;
+ (BOOL)createZip:(NSString *)path withDir:(NSString *)directoryPath keepParentDir:(BOOL)keepParentDirectory withPassword:(NSString *)password;

#pragma mark - unzip
// Unzip
+ (BOOL)unzip:(NSString *)path to:(NSString *)aToPath;
//+ (BOOL)unzip:(NSString *)path to:(NSString *)aToPath delegate:(id<KCZipDelegate>)delegate;

+ (BOOL)unzip:(NSString *)path to:(NSString *)aToPath overwrite:(BOOL)overwrite password:(NSString *)password error:(NSError * *)error;
//+ (BOOL)unzip:(NSString *)path to:(NSString *)aToPath overwrite:(BOOL)overwrite password:(NSString *)password error:(NSError * *)error delegate:(id<KCZipDelegate>)delegate;

//+ (BOOL)unzip:(NSString *)path
//    to:(NSString *)aToPath
//    progressBlock:(void (^)(NSString *entry, unz_file_info zipInfo, long entryNumber, long total))progressBlock
//    completionBlock:(void (^)(NSString *path, BOOL succeeded, NSError *error))completionBlock;

//+ (BOOL)unzip:(NSString *)path
//    to:(NSString *)aToPath
//    overwrite:(BOOL)overwrite
//    password:(NSString *)password
//    progressBlock:(void (^)(NSString *entry, unz_file_info zipInfo, long entryNumber, long total))progressBlock
//    completionBlock:(void (^)(NSString *path, BOOL succeeded, NSError *error))completionBlock;


- (instancetype)initWithPath:(NSString *)path;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL open;
- (BOOL)writeFile:(NSString *)path withPassword:(NSString *)password;
- (BOOL)writeFolderAtPath:(NSString *)path withFolderName:(NSString *)folderName withPassword:(NSString *)password;
- (BOOL)writeFileAtPath:(NSString *)path withFileName:(NSString *)fileName withPassword:(NSString *)password;
- (BOOL)writeData:(NSData *)data filename:(NSString *)filename withPassword:(NSString *)password;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL close;

@end



#endif /* _KCZIPARCHIVE_H */
