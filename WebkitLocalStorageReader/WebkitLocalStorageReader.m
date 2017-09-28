#import "WebkitLocalStorageReader.h"

@implementation WebkitLocalStorageReader

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(get:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *databaseName = @"file__0.localstorage";

    //Get Library path
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                                NSUserDomainMask, YES);
    NSString *libraryDir = [libraryPaths objectAtIndex:0];

    // Acording to this link, the database might be located in the cache folder but it wasn't for me.
    //https://gist.github.com/shazron/2127546
    NSString *databasePath = [libraryDir
                              stringByAppendingPathComponent:@"WebKit/WebsiteData/LocalStorage/"];
    //stringByAppendingPathComponent:@"Caches/"];

    NSString *databaseFile = [databasePath
                              stringByAppendingPathComponent:databaseName];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    BOOL webkitDb = [fileManager fileExistsAtPath:databaseFile];

    if (webkitDb) {

        sqlite3* db = NULL;
        sqlite3_stmt* stmt =NULL;
        int rc=0;
        NSMutableDictionary *kv = [NSMutableDictionary dictionaryWithDictionary:@{}];

        // int len = 0;
        rc = sqlite3_open_v2([databaseFile UTF8String], &db, SQLITE_OPEN_READONLY , NULL);
        if (SQLITE_OK != rc)
        {
            sqlite3_close(db);
            NSLog(@"Failed to open db connection");
        }
        else
        {
            NSString  * query = @"SELECT key,value FROM ItemTable";

            rc =sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt, NULL);


            if (rc == SQLITE_OK)
            {
                while(sqlite3_step(stmt) == SQLITE_ROW )
                {
                    // Get key text
                    const char *key = (const char *)sqlite3_column_text(stmt, 0);
                    NSString *keyString =[[NSString alloc] initWithUTF8String:key];

                    // Get value as String
                    const void *bytes = sqlite3_column_blob(stmt, 1);
                    int length = sqlite3_column_bytes(stmt, 1);
                    NSData *myData = [[NSData alloc] initWithBytes:bytes length:length];
                    NSString *string = [[NSString alloc] initWithData:myData encoding:NSUTF16LittleEndianStringEncoding];

                    if (string) {
                        [kv setObject:string forKey:keyString];
                    } else {
                        [kv setObject:@"" forKey:keyString];
                    }
                                    }
                sqlite3_finalize(stmt);
            }
            else
            {
                NSLog(@"Failed to prepare statement with rc:%d",rc);
            }
            sqlite3_close(db);
        }
        resolve(kv);
    } else {
        resolve(@{});
    }
}

@end
